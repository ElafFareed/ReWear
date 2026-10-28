import Foundation

struct Garment: Identifiable, Codable {

    var id: UUID = UUID()

    var name: String
    var category: String
    var subcategory: String

    var color: String = ""
    var material: String = ""
    var pattern: String = ""
    var season: String = ""
    var fit: String = ""

    // Local path to the saved garment photo
    var photoFilename: String? = nil

    var notes: String = ""
    var dateAdded: Date = Date()

    // MARK: - Repurpose Information

    var condition: String? = nil
    var damageType: String? = nil

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        subcategory: String,
        color: String = "",
        material: String = "",
        pattern: String = "",
        season: String = "",
        fit: String = "",
        photoFilename: String? = nil,
        notes: String = "",
        dateAdded: Date = Date(),
        condition: String? = nil,
        damageType: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.subcategory = subcategory
        self.color = color
        self.material = material
        self.pattern = pattern
        self.season = season
        self.fit = fit
        self.photoFilename = photoFilename
        self.notes = notes
        self.dateAdded = dateAdded
        self.condition = condition
        self.damageType = damageType
    }

    // MARK: - Backward-Compatible Decoding

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(
            UUID.self,
            forKey: .id
        ) ?? UUID()

        name = try container.decode(
            String.self,
            forKey: .name
        )

        category = try container.decode(
            String.self,
            forKey: .category
        )

        subcategory = try container.decode(
            String.self,
            forKey: .subcategory
        )

        color = try container.decodeIfPresent(
            String.self,
            forKey: .color
        ) ?? ""

        material = try container.decodeIfPresent(
            String.self,
            forKey: .material
        ) ?? ""

        pattern = try container.decodeIfPresent(
            String.self,
            forKey: .pattern
        ) ?? ""

        season = try container.decodeIfPresent(
            String.self,
            forKey: .season
        ) ?? ""

        fit = try container.decodeIfPresent(
            String.self,
            forKey: .fit
        ) ?? ""

        photoFilename = try container.decodeIfPresent(
            String.self,
            forKey: .photoFilename
        )

        notes = try container.decodeIfPresent(
            String.self,
            forKey: .notes
        ) ?? ""

        dateAdded = try container.decodeIfPresent(
            Date.self,
            forKey: .dateAdded
        ) ?? Date()

        condition = try container.decodeIfPresent(
            String.self,
            forKey: .condition
        )

        damageType = try container.decodeIfPresent(
            String.self,
            forKey: .damageType
        )
    }
}

