
import Foundation
import UIKit
import CoreML

enum OCMCFRecommendationTest {

    // MARK: - Main Test

    static func run() throws {

        let service = RestyleOCMCFRecommendationService.shared

        guard !service.catalog.isEmpty else {
            print("OCMCF: Load catalog before running recommendations")
            return
        }

        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuOnly

        let encoder = try loadModel(
            "OCMCFImageEncoder",
            configuration: configuration
        )

        let bottomTop = try loadModel(
            "OCMCFBottomTop",
            configuration: configuration
        )

        let topOuterwear = try loadModel(
            "OCMCFCompatibility2",
            configuration: configuration
        )

        let threePiece = try loadModel(
            "OCMCFCompatibility3",
            configuration: configuration
        )

        print("\n===== OCMCF MODEL INPUTS =====")
        describe(bottomTop, name: "Bottom + Top")
        describe(topOuterwear, name: "Top + Outerwear")
        describe(threePiece, name: "Top + Outerwear + Bottom")

        // Cache embeddings during this test.
        var cache: [String: [Float]] = [:]

        func embedding(
            for garment: OCMCFGarment
        ) throws -> [Float] {

            if let existing = cache[garment.id] {
                return existing
            }

            guard let image = service.image(for: garment) else {
                throw TestError.imageMissing(garment.id)
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

            guard let array = prediction
                .featureValue(for: "embedding")?
                .multiArrayValue else {
                throw TestError.embeddingMissing
            }

            let values = (0..<array.count).map {
                array[$0].floatValue
            }

            guard values.count == 64,
                  values.allSatisfy({ $0.isFinite }) else {
                throw TestError.invalidEmbedding
            }

            cache[garment.id] = values

            return values
        }

        let tops = Array(
            service.garments(in: "tops").prefix(5)
        )

        let bottoms = Array(
            service.garments(in: "bottoms").prefix(5)
        )

        let outerwear = Array(
            service.garments(in: "outerwear").prefix(5)
        )

        guard let firstBottom = bottoms.first,
              let firstTop = tops.first,
              let firstOuterwear = outerwear.first else {
            print("OCMCF: Missing required catalog categories")
            return
        }

        // MARK: - Test 1: Bottom -> Top

        print("\n===== BOTTOM -> TOP =====")
        print("Starting bottom:", firstBottom.name)

        var bottomTopResults: [(OCMCFGarment, Double)] = []

        for top in tops {

            let bottomEmbedding = try embedding(
                for: firstBottom
            )

            let topEmbedding = try embedding(
                for: top
            )

            let score = try score(
                model: bottomTop,
                embeddings: [
                    bottomEmbedding,
                    topEmbedding
                ]
            )

            bottomTopResults.append((top, score))
        }

        printResults(bottomTopResults)

        // MARK: - Test 2: Top -> Outerwear

        print("\n===== TOP -> OUTERWEAR =====")
        print("Starting top:", firstTop.name)

        var outerwearResults: [(OCMCFGarment, Double)] = []

        for outer in outerwear {

            let topEmbedding = try embedding(
                for: firstTop
            )

            let outerEmbedding = try embedding(
                for: outer
            )

            let score = try score(
                model: topOuterwear,
                embeddings: [
                    topEmbedding,
                    outerEmbedding
                ]
            )

            outerwearResults.append((outer, score))
        }

        printResults(outerwearResults)

        // MARK: - Test 3: Top + Outerwear -> Bottom

        print("\n===== TOP + OUTERWEAR -> BOTTOM =====")

        print("Starting top:", firstTop.name)
        print("Starting outerwear:", firstOuterwear.name)

        var threePieceResults: [(OCMCFGarment, Double)] = []

        for bottom in bottoms {

            let topEmbedding = try embedding(
                for: firstTop
            )

            let outerEmbedding = try embedding(
                for: firstOuterwear
            )

            let bottomEmbedding = try embedding(
                for: bottom
            )

            let score = try score(
                model: threePiece,
                embeddings: [
                    topEmbedding,
                    outerEmbedding,
                    bottomEmbedding
                ]
            )

            threePieceResults.append((bottom, score))
        }

        printResults(threePieceResults)

        print("\n===== OCMCF TEST COMPLETE =====")
        print("Unique garments encoded:", cache.count)
    }

    // MARK: - Load Core ML Model

    private static func loadModel(
        _ name: String,
        configuration: MLModelConfiguration
    ) throws -> MLModel {

        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "mlmodelc"
        ) else {
            throw TestError.modelMissing(name)
        }

        return try MLModel(
            contentsOf: url,
            configuration: configuration
        )
    }

    // MARK: - Print Model Interface

    private static func describe(
        _ model: MLModel,
        name: String
    ) {

        print("\nMODEL:", name)

        for (key, description) in
            model.modelDescription.inputDescriptionsByName {

            print(
                "Input:",
                key,
                "Type:",
                description.type.rawValue,
                "Shape:",
                description.multiArrayConstraint?.shape ?? []
            )
        }

        for (key, description) in
            model.modelDescription.outputDescriptionsByName {

            print(
                "Output:",
                key,
                "Type:",
                description.type.rawValue,
                "Shape:",
                description.multiArrayConstraint?.shape ?? []
            )
        }
    }

    // MARK: - Create Scorer Input

    private static func makeEmbeddings(
        _ embeddings: [[Float]]
    ) throws -> MLMultiArray {

        guard !embeddings.isEmpty,
              embeddings.allSatisfy({ $0.count == 64 }) else {
            throw TestError.invalidEmbedding
        }

        let rows = embeddings.count

        let tensor = try MLMultiArray(
            shape: [
                NSNumber(value: rows),
                64
            ],
            dataType: .float32
        )

        for row in 0..<rows {
            for col in 0..<64 {

                let index = row * 64 + col

                tensor[index] = NSNumber(
                    value: embeddings[row][col]
                )
            }
        }

        return tensor
    }

    // MARK: - Calculate Compatibility Score

    private static func score(
        model: MLModel,
        embeddings: [[Float]]
    ) throws -> Double {

        let input = try makeEmbeddings(embeddings)

        let features = try MLDictionaryFeatureProvider(
            dictionary: [
                "garment_embeddings": input
            ]
        )

        let prediction = try model.prediction(
            from: features
        )

        guard let output = prediction
            .featureValue(for: "compatibility_score") else {
            throw TestError.scoreMissing
        }

        if let values = output.multiArrayValue {
            guard values.count == 1 else {
                throw TestError.invalidScore
            }

            let value = values[0].doubleValue

            guard value.isFinite else {
                throw TestError.invalidScore
            }

            return value
        }

        let value = output.doubleValue

        guard value.isFinite else {
            throw TestError.invalidScore
        }

        return value
    }

    // MARK: - Print Results

    private static func printResults(
        _ results: [(OCMCFGarment, Double)]
    ) {

        print("Raw model scores:")

        for (garment, score) in results {
            print(
                garment.id,
                "|",
                garment.name,
                "| score:",
                score
            )
        }

        print("\nHighest scores first:")

        for (garment, score) in
            results.sorted(by: { $0.1 > $1.1 }) {

            print(
                garment.name,
                "|",
                score
            )
        }

        print("\nLowest scores first:")

        for (garment, score) in
            results.sorted(by: { $0.1 < $1.1 }) {

            print(
                garment.name,
                "|",
                score
            )
        }
    }

    // MARK: - Errors

    enum TestError: LocalizedError {

        case modelMissing(String)
        case imageMissing(String)
        case embeddingMissing
        case invalidEmbedding
        case scoreMissing
        case invalidScore

        var errorDescription: String? {

            switch self {

            case .modelMissing(let name):
                return "Core ML model missing: \(name)"

            case .imageMissing(let id):
                return "Garment image missing: \(id)"

            case .embeddingMissing:
                return "Encoder embedding output missing"

            case .invalidEmbedding:
                return "Invalid encoder embedding"

            case .scoreMissing:
                return "Compatibility score output missing"

            case .invalidScore:
                return "Invalid compatibility score"
            }
        }
    }
}
