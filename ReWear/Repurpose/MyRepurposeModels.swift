
import Foundation

// MARK: - Existing Repair Mode
// Keep this if RepurposeDamageGuide.swift still needs it.
// Do not declare RepairMode twice in your project.

enum RepairMode: String, Hashable, CaseIterable, Identifiable {
    case repair
    case repurpose

    var id: String { rawValue }
}

// MARK: - Repurpose Guide

struct MyRepurposeGuide: Identifiable, Decodable, Hashable {

    let mode: String
    let provenance: String
    let id: String
    let title: String
    let result: String
    let summary: String

    let sourceCategories: [String]
    let suitableConditions: [String]
    let bestFabrics: [String]

    let difficulty: String
    let minutes: Int
    let noSew: Bool

    let materials: [String]
    let tools: [String]
    let steps: [MyRepurposeStep]

    let benefit: String
    let symbol: String
}

// MARK: - Instruction Step

struct MyRepurposeStep: Decodable, Hashable {

    let title: String
    let heading: String
    let detail: String
    let tip: String
    let symbol: String
    let action: String?
}

// MARK: - Offline Guide Library

enum MyRepurposeLibrary {

    static let guides: [MyRepurposeGuide] = {

        guard let url = Bundle.main.url(
            forResource: "guides",
            withExtension: "json"
        ) else {
            print("Repurpose guides.json not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)

            let allGuides = try JSONDecoder().decode(
                [MyRepurposeGuide].self,
                from: data
            )

            return allGuides.filter {
                $0.mode == "repurpose"
            }

        } catch {
            print("Failed to load Repurpose guides: \(error)")
            return []
        }
    }()

    // MARK: - Damage-Aware Project Rules
    //
    // These IDs come from guides.json.
    //
    // Each list:
    // - determines which projects may be recommended
    // - orders them from higher to lower priority
    //
    // These are curated suitability rules, not labels
    // provided by the original JSON dataset.
    //
    // Users must still inspect the actual damaged garment
    // and use only clean, sound fabric where required.

    private static let projectsByDamage: [String: [String]] = [

        // Extensive bleach damage:
        // Prefer projects using smaller, unaffected sections.
        // Avoid load-bearing projects requiring strong panels.

        "severe-bleach-damage": [
            "scrap-bunting",
            "tshirt-yarn",
            "tshirt-towel",
            "denim-patches",
            "drawstring-pouch",
            "dress-top",
            "jeans-shorts",
            "sweater-gloves",
            "draught-stopper",
            "hat-mug-cosy",
            "skirt-apron",
            "shorts-wall-organizer",
            "shoe-planter",
            "shoe-doorstop",
            "boot-vase",
            "bag-hanging-planter",
            "hat-planter-cover",
            "belt-cable-ties",
            "strap-keyring",
            "lace-lanyard"
        ],

        // Permanent stains:
        // Prefer projects where visibly stained sections
        // can be cut away or covered.
        // Fabric must be cleaned and suitable for reuse.

        "permanent-stains": [
            "scrap-bunting",
            "tshirt-towel",
            "tshirt-yarn",
            "drawstring-pouch",
            "denim-patches",
            "dress-top",
            "jeans-shorts",
            "shirt-tote",
            "denim-tote",
            "skirt-apron",
            "shorts-wall-organizer",
            "sweater-pillow",
            "sweater-gloves",
            "draught-stopper",
            "jacket-pet-bed",
            "laptop-sleeve",
            "jacket-vest",
            "hat-mug-cosy",
            "scarf-wrap-bag",
            "shoe-planter",
            "shoe-doorstop",
            "boot-vase",
            "bag-hanging-planter",
            "hat-planter-cover",
            "belt-cable-ties",
            "strap-keyring",
            "lace-lanyard"
        ],

        // Large tears and holes:
        // Prefer projects using intact remaining sections.
        // Structural projects require sufficient sound fabric.

        "large-tears-holes": [
            "tshirt-yarn",
            "denim-patches",
            "scrap-bunting",
            "tshirt-towel",
            "drawstring-pouch",
            "jeans-shorts",
            "dress-top",
            "sweater-gloves",
            "draught-stopper",
            "sweater-pillow",
            "hat-mug-cosy",
            "shorts-wall-organizer",
            "skirt-apron",
            "shirt-tote",
            "denim-tote",
            "jacket-vest",
            "scarf-wrap-bag",
            "shoe-planter",
            "shoe-doorstop",
            "boot-vase",
            "strap-keyring",
            "belt-cable-ties",
            "lace-lanyard",
            "hat-planter-cover",
            "bag-hanging-planter"
        ],

        // Worn-out, thin or weak fabric:
        // Avoid projects that rely on fabric strength,
        // like tote bags and garment reinforcements.

        "worn-out-fabric": [
            "tshirt-towel",
            "tshirt-yarn",
            "scrap-bunting",
            "draught-stopper",
            "shoe-planter",
            "shoe-doorstop",
            "boot-vase",
            "hat-planter-cover",
            "bag-hanging-planter"
        ]
    ]

    // MARK: - Personalized Recommendations

    static func recommendations(
        for garment: RepurposeGarment
    ) -> [MyRepurposeGuide] {

        // 1. Specific garment type

        let category = normalize(
            garment.subcategory.isEmpty
                ? garment.category
                : garment.subcategory
        )

        // 2. Garment fabric

        let material = normalize(garment.material)

        // 3. General garment condition

        let condition = normalize(
            garment.condition ?? "damaged"
        )

        // 4. Exact selected damage

        guard let damageType = garment.damageType,
              let allowedIDs = projectsByDamage[damageType]
        else {
            return []
        }

        // 5. Filter by category, fabric, and condition

        let compatibleGuides = guides.filter { guide in

            let matchesCategory =
                guide.sourceCategories.contains {
                    normalize($0) == category
                }

            let matchesMaterial =
                guide.bestFabrics.isEmpty ||
                guide.bestFabrics.contains {
                    normalize($0) == material
                }

            let matchesCondition =
                guide.suitableConditions.contains {
                    normalize($0) == condition
                }

            return matchesCategory
                && matchesMaterial
                && matchesCondition
        }

        // 6. Keep only projects curated for the damage.
        // Preserve the preferred order for that damage.

        let guidesByID = Dictionary(
            uniqueKeysWithValues: compatibleGuides.map {
                ($0.id, $0)
            }
        )

        return allowedIDs.compactMap { id in
            guidesByID[id]
        }
    }

    // MARK: - Normalize Category / Material Names

    private static func normalize(
        _ value: String
    ) -> String {

        let cleaned = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "&", with: "and")

        switch cleaned {

        case "tshirts", "tshirt", "tee", "tees":
            return "tshirt"

        case "tanktops", "tanktop":
            return "tanktop"

        case "jean", "jeans":
            return "jeans"

        case "trousers", "trouser", "pants":
            return "pants"

        case "dresses", "dress":
            return "dress"

        case "jackets", "jacket":
            return "jacket"

        case "sweaters", "sweater", "jumper":
            return "sweater"

        case "knitted", "knitwear", "knit":
            return "knit"

        default:
            return cleaned
        }
    }
}
