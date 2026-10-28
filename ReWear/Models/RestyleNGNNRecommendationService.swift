
import Foundation
import CoreML
import UIKit

// MARK: - Scored Garment

struct RestyleScoredGarment: Identifiable {

    let garment: Garment
    let score: Float

    var id: UUID {
        garment.id
    }
}

// MARK: - Recommendation Errors

enum RestyleRecommendationError: LocalizedError {

    case missingCategoryNames
    case invalidCategoryNames
    case categoryNotMapped(String)
    case startingPhotoMissing
    case noCompatibleCandidates

    var errorDescription: String? {

        switch self {

        case .missingCategoryNames:
            return "ngnn_category_names.json was not found."

        case .invalidCategoryNames:
            return "The NGNN category mapping is invalid."

        case .categoryNotMapped(let name):
            return "The category '\(name)' is not supported by NGNN."

        case .startingPhotoMissing:
            return "The starting garment needs a photo."

        case .noCompatibleCandidates:
            return "No compatible wardrobe candidates could be scored."
        }
    }
}

// MARK: - Category Record

private struct NGNNNamedCategory: Decodable {

    let id: Int
    let name: String
}

// MARK: - NGNN Recommendation Service

final class RestyleNGNNRecommendationService {

    private let extractor: InceptionFeatureService
    private let inputBuilder: NGNNInputBuilder
    private let scorer: NGNNCompatibilityService

    private let categoriesByName: [String: Int]

    // MARK: - Initialize

    init() throws {

        // Load category names

        guard let namesURL = Bundle.main.url(
            forResource: "ngnn_category_names",
            withExtension: "json"
        ) else {
            throw RestyleRecommendationError.missingCategoryNames
        }

        let namesData = try Data(contentsOf: namesURL)

        let records = try JSONDecoder().decode(
            [NGNNNamedCategory].self,
            from: namesData
        )

        // Load NGNN supported category IDs

        guard let mappingURL = Bundle.main.url(
            forResource: "cid2rcid_100",
            withExtension: "json"
        ) else {
            throw NGNNInputError.missingCategoryMapping
        }

        let mappingData = try Data(contentsOf: mappingURL)

        let slotMapping = try JSONDecoder().decode(
            [String: Int].self,
            from: mappingData
        )

        let supportedIDs = Set(
            slotMapping.keys.compactMap(Int.init)
        )

        let slots = Set(slotMapping.values)

        // Verify that all 120 categories match NGNN

        guard supportedIDs.count == 120,
              slots == Set(0..<120),
              records.count == supportedIDs.count,
              Set(records.map(\.id)) == supportedIDs else {

            throw RestyleRecommendationError.invalidCategoryNames
        }

        // Build category name -> original category ID

        var lookup: [String: Int] = [:]

        for category in records {

            let normalizedName = Self.normalize(
                category.name
            )

            guard lookup[normalizedName] == nil else {
                throw RestyleRecommendationError.invalidCategoryNames
            }

            lookup[normalizedName] = category.id
        }

        categoriesByName = lookup

        // Initialize existing Core ML services

        extractor = try InceptionFeatureService()

        inputBuilder = try NGNNInputBuilder()

        scorer = try NGNNCompatibilityService()
    }

    // MARK: - Rank Wardrobe Garments

    func rank(
        startingGarment: Garment,
        candidates: [Garment],
        imageFor: (Garment) -> UIImage?
    ) throws -> [RestyleScoredGarment] {

        // 1. Get starting garment image

        guard let startingImage = imageFor(startingGarment) else {

            throw RestyleRecommendationError.startingPhotoMissing
        }

        // 2. Get starting category ID

        let startingCategoryID = try categoryID(
            for: startingGarment
        )

        // 3. Extract starting garment features

        let startingFeatures = try extractor.extractFeatures(
            from: startingImage
        )

        var results: [RestyleScoredGarment] = []

        // 4. Compare with wardrobe candidates

        for candidate in candidates {

            // Do not recommend the garment itself

            if candidate.id == startingGarment.id {
                continue
            }

            // Resolve candidate category

            guard let candidateCategoryID = try? categoryID(
                for: candidate
            ) else {
                continue
            }

            // NGNNInputBuilder requires unique categories

            if candidateCategoryID == startingCategoryID {
                continue
            }

            // Candidate must have a photo

            guard let candidateImage = imageFor(candidate) else {
                continue
            }

            do {

                // 5. Extract candidate features

                let candidateFeatures = try extractor.extractFeatures(
                    from: candidateImage
                )

                // 6. Create NGNN inputs

                let input = try inputBuilder.build(
                    garments: [

                        NGNNGarmentFeature(
                            categoryID: startingCategoryID,
                            features: startingFeatures
                        ),

                        NGNNGarmentFeature(
                            categoryID: candidateCategoryID,
                            features: candidateFeatures
                        )
                    ]
                )

                // 7. Run compatibility model

                let score = try scorer.predict(
                    images: input.images,
                    graph: input.graph
                )

                // Reject invalid model outputs

                guard score.isFinite else {
                    continue
                }

                // 8. Save recommendation

                results.append(
                    RestyleScoredGarment(
                        garment: candidate,
                        score: score
                    )
                )

            } catch {

                print(
                    "NGNN skipped \(candidate.name): \(error)"
                )
            }
        }

        // Check if any candidates were scored

        guard !results.isEmpty else {

            throw RestyleRecommendationError.noCompatibleCandidates
        }

        // Higher compatibility scores first

        return results.sorted {
            $0.score > $1.score
        }
    }

    // MARK: - Find Garment Category

    private func categoryID(
        for garment: Garment
    ) throws -> Int {

        let names = [
            garment.subcategory,
            garment.category
        ]

        for name in names {

            let normalized = Self.normalize(name)

            if let id = categoriesByName[normalized] {
                return id
            }
        }

        let name = garment.subcategory.isEmpty
            ? garment.category
            : garment.subcategory

        throw RestyleRecommendationError.categoryNotMapped(
            name
        )
    }

    // MARK: - Normalize Category Names

    private static func normalize(
        _ name: String
    ) -> String {

        let normalized = name
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "'", with: "")

        switch normalized {

        case "tshirt", "tee", "tees":
            return "tshirts"

        case "jean":
            return "jeans"

        case "skirt":
            return "skirts"

        case "dress":
            return "dresses"

        case "blazer":
            return "blazers"

        case "jacket":
            return "jackets"

        case "sneaker":
            return "sneakers"

        case "hoodie":
            return "hoodies"

        case "tanktop":
            return "tanktops"

        case "sweater":
            return "sweaters"

        case "coat":
            return "coats"

        case "boot":
            return "boots"

        default:
            return normalized
        }
    }
}
