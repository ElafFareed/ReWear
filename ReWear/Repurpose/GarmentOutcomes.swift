
import Foundation

// MARK: - Outcome Counts

struct OutcomeCounts: Decodable, Hashable {

    var reuse: Int = 0
    var export: Int = 0
    var repair: Int = 0
    var remake: Int = 0
    var recycle: Int = 0
    var energyRecovery: Int = 0

    var total: Int {
        reuse + export + repair + remake + recycle + energyRecovery
    }

    var wearable: Int {
        reuse + export + repair
    }

    var noLongerWorn: Int {
        remake + recycle + energyRecovery
    }

    var wearableShare: Double {
        total == 0 ? 0 : Double(wearable) / Double(total)
    }

    var noLongerWornShare: Double {
        total == 0 ? 0 : Double(noLongerWorn) / Double(total)
    }
}

// MARK: - Outcome Statistics

struct OutcomeStat: Hashable {

    let counts: OutcomeCounts

    // String identifiers correspond to keys in garment_outcomes.json
    let category: String?
    let condition: String?

    let exactType: Bool
}

// MARK: - Garment Outcomes Service

final class GarmentOutcomes: Decodable {

    static let shared = GarmentOutcomes.load(from: .main)

    static let minimumSample = 30

    // MARK: - Source Information

    struct Source: Decodable, Hashable {
        let name: String
        let publisher: String
        let url: String
        let license: String
    }

    // MARK: - JSON Properties

    let source: Source
    let itemCount: Int

    let categories: [String: [String: OutcomeCounts]]
    let groups: [String: [String: OutcomeCounts]]
    let all: [String: OutcomeCounts]

    // MARK: - Overall Statistics

    func overall(condition: String? = nil) -> OutcomeStat? {

        let conditionKey = condition ?? "any"

        guard let counts = all[conditionKey],
              counts.total >= Self.minimumSample
        else {
            return nil
        }

        return OutcomeStat(
            counts: counts,
            category: nil,
            condition: condition,
            exactType: false
        )
    }

    // MARK: - Category Statistics

    // Category and group are JSON keys, e.g.
    // category: "jeans", group: "bottoms"
    //
    // Conditions: "great", "worn", "damaged"
    // Pass nil for all conditions.

    func stat(
        for category: String,
        group: String? = nil,
        condition: String? = nil
    ) -> OutcomeStat? {

        let conditionKey = condition ?? "any"

        // Try exact category and condition first.

        if let counts = categories[category]?[conditionKey],
           counts.total >= Self.minimumSample {

            return OutcomeStat(
                counts: counts,
                category: category,
                condition: condition,
                exactType: true
            )
        }

        // Try broader group and condition.

        if let group,
           let counts = groups[group]?[conditionKey],
           counts.total >= Self.minimumSample {

            return OutcomeStat(
                counts: counts,
                category: category,
                condition: condition,
                exactType: false
            )
        }

        // Fall back to category statistics across all conditions.

        if let counts = categories[category]?["any"],
           counts.total >= Self.minimumSample {

            return OutcomeStat(
                counts: counts,
                category: category,
                condition: nil,
                exactType: true
            )
        }

        // Finally, try broader group across all conditions.

        if let group,
           let counts = groups[group]?["any"],
           counts.total >= Self.minimumSample {

            return OutcomeStat(
                counts: counts,
                category: category,
                condition: nil,
                exactType: false
            )
        }

        return nil
    }

    // MARK: - Load JSON

    static func load(from bundle: Bundle) -> GarmentOutcomes? {

        guard let url = bundle.url(
            forResource: "garment_outcomes",
            withExtension: "json"
        ) else {
            print("garment_outcomes.json was not found in the app bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(
                GarmentOutcomes.self,
                from: data
            )
        } catch {
            print("Failed to decode garment outcomes: \(error)")
            return nil
        }
    }
}

