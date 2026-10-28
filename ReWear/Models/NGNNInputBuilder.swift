
import Foundation
import CoreML

enum NGNNInputError: LocalizedError {
    case missingCategoryMapping
    case invalidCategoryMapping
    case unsupportedCategory(Int)
    case invalidFeatures
    case duplicateCategory(Int)
    case insufficientGarments

    var errorDescription: String? {
        switch self {
        case .missingCategoryMapping:
            return "The NGNN category mapping file was not found."
        case .invalidCategoryMapping:
            return "The NGNN category mapping is invalid."
        case .unsupportedCategory(let id):
            return "Category \(id) is not supported by NGNN."
        case .invalidFeatures:
            return "Each garment must have 2,048 image features."
        case .duplicateCategory(let id):
            return "Category \(id) appears more than once."
        case .insufficientGarments:
            return "At least two garments are needed to score an outfit."
        }
    }
}

struct NGNNGarmentFeature {
    let categoryID: Int
    let features: MLMultiArray
}

struct NGNNInput {
    let images: MLMultiArray
    let graph: MLMultiArray
}

final class NGNNInputBuilder {

    private let categoryCount = 120
    private let featureCount = 2048

    private let categoryMapping: [String: Int]

    init() throws {
        guard let url = Bundle.main.url(
            forResource: "cid2rcid_100",
            withExtension: "json"
        ) else {
            throw NGNNInputError.missingCategoryMapping
        }

        let data = try Data(contentsOf: url)

        categoryMapping = try JSONDecoder().decode(
            [String: Int].self,
            from: data
        )

        let slots = Set(categoryMapping.values)

        guard categoryMapping.count == 120,
              slots == Set(0..<120) else {
            throw NGNNInputError.invalidCategoryMapping
        }
    }

    func build(
        garments: [NGNNGarmentFeature]
    ) throws -> NGNNInput {

        guard garments.count >= 2 else {
            throw NGNNInputError.insufficientGarments
        }

        let images = try MLMultiArray(
            shape: [1, 120, 2048],
            dataType: .float32
        )

        let graph = try MLMultiArray(
            shape: [1, 120, 120],
            dataType: .float32
        )

        let imagePointer = images.dataPointer
            .bindMemory(
                to: Float32.self,
                capacity: categoryCount * featureCount
            )

        let graphPointer = graph.dataPointer
            .bindMemory(
                to: Float32.self,
                capacity: categoryCount * categoryCount
            )

        imagePointer.initialize(
            repeating: 0,
            count: categoryCount * featureCount
        )

        graphPointer.initialize(
            repeating: 0,
            count: categoryCount * categoryCount
        )

        var selectedSlots: [Int] = []
        var usedSlots = Set<Int>()

        for garment in garments {

            guard let slot = categoryMapping[
                String(garment.categoryID)
            ] else {
                throw NGNNInputError.unsupportedCategory(
                    garment.categoryID
                )
            }

            guard !usedSlots.contains(slot) else {
                throw NGNNInputError.duplicateCategory(
                    garment.categoryID
                )
            }

            guard garment.features.count == featureCount else {
                throw NGNNInputError.invalidFeatures
            }

            usedSlots.insert(slot)
            selectedSlots.append(slot)

            for featureIndex in 0..<featureCount {
                let destination =
                    slot * featureCount + featureIndex

                imagePointer[destination] =
                    garment.features[featureIndex].floatValue
            }
        }

        // Original NGNN graph:
        // Every garment connects to all other garments.
        // No self-connections.
        // Connections are normalized by (n - 1).

        let connectionWeight =
            Float32(1.0 / Double(garments.count - 1))

        for source in selectedSlots {
            for destination in selectedSlots {

                if source == destination {
                    continue
                }

                let index =
                    source * categoryCount + destination

                graphPointer[index] = connectionWeight
            }
        }

        return NGNNInput(
            images: images,
            graph: graph
        )
    }
}

