
import Foundation

struct RepurposeGarment: Identifiable, Hashable {

    let id: UUID

    // Optional connection to a saved wardrobe item.
    var wardrobeGarmentID: UUID?

    // Details entered on What's Your Piece?
    var category: String
    var subcategory: String
    var color: String
    var pattern: String
    var material: String

    // Details entered in Repurpose.
    var condition: String?
    var damageType: String?

    init(
        id: UUID = UUID(),
        wardrobeGarmentID: UUID? = nil,
        category: String = "",
        subcategory: String = "",
        color: String = "",
        pattern: String = "",
        material: String = "",
        condition: String? = nil,
        damageType: String? = nil
    ) {
        self.id = id
        self.wardrobeGarmentID = wardrobeGarmentID
        self.category = category
        self.subcategory = subcategory
        self.color = color
        self.pattern = pattern
        self.material = material
        self.condition = condition
        self.damageType = damageType
    }
}

// MARK: - Convert Wardrobe Garment to Repurpose Garment
 
extension RepurposeGarment {

   init(from garment: Garment) {
       self.init(
           wardrobeGarmentID: garment.id,
           category: garment.category,
           subcategory: garment.subcategory,
           color: garment.color,
           pattern: garment.pattern,
           material: garment.material
       )
   }
}
