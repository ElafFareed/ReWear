
import Foundation
import UIKit
import CoreML

// MARK: - Recommendation Result

struct OCMCFRecommendation: Identifiable {
    let garment: OCMCFGarment
    let score: Double

    var id: String { garment.id }
}

// MARK: - Recommendation Engine

final class OCMCFRecommendationEngine {

    static let shared = OCMCFRecommendationEngine()

    private let catalogService =
        RestyleOCMCFRecommendationService.shared

    private let encoder: MLModel
    private let bottomTopModel: MLModel
    private let topOuterwearModel: MLModel
    private let threePieceModel: MLModel

    // Reuse computed embeddings instead of encoding
    // the same garment for every recommendation.
    private var embeddingCache: [String: [Float]] = [:]

    // This engine should be used serially on one queue.
    private init() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .cpuOnly

            encoder = try Self.loadModel(
                "OCMCFImageEncoder",
                configuration: config
            )

            bottomTopModel = try Self.loadModel(
                "OCMCFBottomTop",
                configuration: config
            )

            topOuterwearModel = try Self.loadModel(
                "OCMCFCompatibility2",
                configuration: config
            )

            threePieceModel = try Self.loadModel(
                "OCMCFCompatibility3",
                configuration: config
            )

            print("OCMCF recommendation engine initialized")

        } catch {
            fatalError(
                "OCMCF model initialization failed: \(error)"
            )
        }
    }

    // MARK: - Bottom -> Top

    func recommendTops(
        for bottom: OCMCFGarment,
        limit: Int = 2
    ) throws -> [OCMCFRecommendation] {

        guard bottom.category == "bottoms" else {
            throw EngineError.invalidCategory
        }

        let anchorEmbedding = try embedding(for: bottom)

        let candidates = catalogService.garments(
            in: "tops"
        )

        return try rank(
            candidates: candidates,
            model: bottomTopModel,
            anchorEmbeddings: [anchorEmbedding],
            limit: limit
        )
    }

    // MARK: - Top -> Outerwear

    func recommendOuterwear(
        for top: OCMCFGarment,
        limit: Int = 2
    ) throws -> [OCMCFRecommendation] {

        guard top.category == "tops" else {
            throw EngineError.invalidCategory
        }

        let anchorEmbedding = try embedding(for: top)

        let candidates = catalogService.garments(
            in: "outerwear"
        )

        return try rank(
            candidates: candidates,
            model: topOuterwearModel,
            anchorEmbeddings: [anchorEmbedding],
            limit: limit
        )
    }

    // MARK: - Top + Outerwear -> Bottom

    func recommendBottoms(
        for top: OCMCFGarment,
        outerwear: OCMCFGarment,
        limit: Int = 2
    ) throws -> [OCMCFRecommendation] {

        guard top.category == "tops",
              outerwear.category == "outerwear" else {
            throw EngineError.invalidCategory
        }

        let topEmbedding = try embedding(for: top)
        let outerEmbedding = try embedding(for: outerwear)

        let candidates = catalogService.garments(
            in: "bottoms"
        )

        return try rank(
            candidates: candidates,
            model: threePieceModel,
            anchorEmbeddings: [
                topEmbedding,
                outerEmbedding
            ],
            limit: limit
        )
    }
    
    // MARK: - Recommend Tops From User Image

    func recommendTops(
        forImage image: UIImage,
        limit: Int = 5
    ) throws -> [OCMCFRecommendation] {

        // Encode the user's actual bottom image
        let anchorEmbedding = try embedding(forImage: image)

        // Search all catalog tops
        let candidates = catalogService.garments(in: "tops")

        return try rank(
            candidates: candidates,
            model: bottomTopModel,
            anchorEmbeddings: [anchorEmbedding],
            limit: limit
        )
    }

    // MARK: - Recommend Outerwear From User Image

    func recommendOuterwear(
        forImage image: UIImage,
        limit: Int = 5
    ) throws -> [OCMCFRecommendation] {

        // Encode the user's actual top image
        let anchorEmbedding = try embedding(forImage: image)

        // Search all catalog outerwear
        let candidates = catalogService.garments(in: "outerwear")

        return try rank(
            candidates: candidates,
            model: topOuterwearModel,
            anchorEmbeddings: [anchorEmbedding],
            limit: limit
        )
    }

    // MARK: - Encode User Image

    private func embedding(
        forImage image: UIImage
    ) throws -> [Float] {

        // Same preprocessing used for catalog garments
        let input = try OCMCFEncoderSmokeTest.makeInput(
            from: image
        )

        let features = try MLDictionaryFeatureProvider(
            dictionary: [
                "garment_image": input
            ]
        )

        let prediction = try encoder.prediction(
            from: features
        )

        guard let output = prediction
            .featureValue(for: "embedding")?
            .multiArrayValue else {

            throw EngineError.embeddingMissing
        }

        let values = (0..<output.count).map {
            output[$0].floatValue
        }

        guard values.count == 64,
              values.allSatisfy({ $0.isFinite }) else {

            throw EngineError.invalidEmbedding
        }

        return values
    }


    // MARK: - Rank Candidates

    private func rank(
        candidates: [OCMCFGarment],
        model: MLModel,
        anchorEmbeddings: [[Float]],
        limit: Int
    ) throws -> [OCMCFRecommendation] {

        var results: [OCMCFRecommendation] = []

        for candidate in candidates {

            let candidateEmbedding = try embedding(
                for: candidate
            )

            let allEmbeddings =
                anchorEmbeddings + [candidateEmbedding]

            let score = try compatibilityScore(
                model: model,
                embeddings: allEmbeddings
            )

            results.append(
                OCMCFRecommendation(
                    garment: candidate,
                    score: score
                )
            )
        }

        // OCMCF ranks scores in descending order.
        results.sort { $0.score > $1.score }

        return Array(results.prefix(max(0, limit)))
    }

    // MARK: - Encode Garment

    private func embedding(
        for garment: OCMCFGarment
    ) throws -> [Float] {

        if let cached = embeddingCache[garment.id] {
            return cached
        }

        guard let image = catalogService.image(
            for: garment
        ) else {
            throw EngineError.imageMissing(garment.id)
        }

        let input = try OCMCFEncoderSmokeTest.makeInput(
            from: image
        )

        let features = try MLDictionaryFeatureProvider(
            dictionary: ["garment_image": input]
        )

        let prediction = try encoder.prediction(
            from: features
        )

        guard let output = prediction
            .featureValue(for: "embedding")?
            .multiArrayValue else {
            throw EngineError.embeddingMissing
        }

        let values = (0..<output.count).map {
            output[$0].floatValue
        }

        guard values.count == 64,
              values.allSatisfy({ $0.isFinite }) else {
            throw EngineError.invalidEmbedding
        }

        embeddingCache[garment.id] = values

        return values
    }

    // MARK: - Score an Outfit

    private func compatibilityScore(
        model: MLModel,
        embeddings: [[Float]]
    ) throws -> Double {

        let tensor = try MLMultiArray(
            shape: [
                NSNumber(value: embeddings.count),
                64
            ],
            dataType: .float32
        )

        for row in embeddings.indices {
            guard embeddings[row].count == 64 else {
                throw EngineError.invalidEmbedding
            }

            for column in 0..<64 {
                tensor[row * 64 + column] = NSNumber(
                    value: embeddings[row][column]
                )
            }
        }

        let features = try MLDictionaryFeatureProvider(
            dictionary: [
                "garment_embeddings": tensor
            ]
        )

        let prediction = try model.prediction(
            from: features
        )

        guard let output = prediction
            .featureValue(for: "compatibility_score") else {
            throw EngineError.scoreMissing
        }

        let score: Double

        if let array = output.multiArrayValue {
            guard array.count == 1 else {
                throw EngineError.invalidScore
            }
            score = array[0].doubleValue
        } else {
            score = output.doubleValue
        }

        guard score.isFinite else {
            throw EngineError.invalidScore
        }

        return score
    }

    // MARK: - Load Model

    private static func loadModel(
        _ name: String,
        configuration: MLModelConfiguration
    ) throws -> MLModel {

        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "mlmodelc"
        ) else {
            throw EngineError.modelMissing(name)
        }

        return try MLModel(
            contentsOf: url,
            configuration: configuration
        )
    }

    // MARK: - Errors

    enum EngineError: LocalizedError {

        case modelMissing(String)
        case invalidCategory
        case imageMissing(String)
        case embeddingMissing
        case invalidEmbedding
        case scoreMissing
        case invalidScore

        var errorDescription: String? {
            switch self {
            case .modelMissing(let name):
                return "Missing Core ML model: \(name)"
            case .invalidCategory:
                return "Incorrect garment category for workflow."
            case .imageMissing(let id):
                return "Missing garment image: \(id)"
            case .embeddingMissing:
                return "Encoder output missing."
            case .invalidEmbedding:
                return "Invalid 64-dimensional embedding."
            case .scoreMissing:
                return "Compatibility output missing."
            case .invalidScore:
                return "Invalid compatibility score."
            }
        }
    }
}
