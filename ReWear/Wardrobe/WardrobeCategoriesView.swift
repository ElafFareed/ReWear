import SwiftUI

struct WardrobeCategoriesView: View {

    @State private var selectedCategory = "Tops"
    @State private var selectedSubcategory: String? = nil
    @State private var showGarmentDetails = false

    private let categories: [String: [String]] = [
        "Tops": [
            "T-Shirts", "Blouses", "Tank Tops", "Sweaters",
            "Cardigans", "Men's T-Shirts", "Men's Casual Shirts",
            "Sweatshirts", "Hoodies"
        ],
        "Bottoms": [
            "Jeans", "Pants", "Shorts", "Skirts", "Skinny Jeans",
            "Boyfriend Jeans", "Straight Leg Jeans", "Leggings",
            "Activewear Pants", "Men's Jeans", "Men's Casual Pants",
            "Capri & Cropped Pants"
        ],
        "Dresses & One-Pieces": [
            "Dresses", "Day Dresses", "Cocktail Dresses",
            "Gowns", "Rompers"
        ],
        "Outerwear": [
            "Jackets", "Coats", "Blazers", "Vests", "Men's Jackets"
        ],
        "Shoes": [
            "Boots", "Ankle Booties", "Knee High Boots",
            "Over-The-Knee Boots", "Pumps", "Sandals", "Flats",
            "Sneakers", "Men's Sneakers", "Loafers & Moccasins",
            "Oxfords"
        ],
        "Accessories": [
            "Bags", "Handbags", "Tote Bags", "Shoulder Bags",
            "Clutches", "Backpacks", "Messenger Bags", "Belts",
            "Hats", "Men's Hats", "Sunglasses", "Men's Sunglasses",
            "Jewelry", "Watches", "Men's Watches", "Necklaces",
            "Earrings", "Rings", "Bracelets & Bangles", "Scarves",
            "Socks", "Gloves", "Hair Accessories"
        ]
    ]

    private let categoryOrder = [
        "Tops",
        "Bottoms",
        "Dresses & One-Pieces",
        "Outerwear",
        "Shoes",
        "Accessories"
    ]

    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("REWEAR / STUDIO")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(RestyleColors.textSecondary)
                    
                    Text("CHOOSE YOUR PIECE.")
                        .font(RestyleTypography.editorial(28))
                        .foregroundStyle(RestyleColors.textPrimary)
                }
                
                Spacer()
                
                Image(systemName: "hanger")
                    .font(.system(size: 22))
                    .foregroundStyle(RestyleColors.textPrimary)
            }
            .padding(.horizontal, RestyleSpacing.screenPadding)
            .padding(.top, 20)
            
            Text("Select a category and then choose the type of clothing.")
                .font(RestyleTypography.body)
                .foregroundStyle(RestyleColors.textSecondary)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.horizontal, RestyleSpacing.screenPadding)
                .padding(.top, 10)
            
            // MARK: - Main Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categoryOrder, id: \.self) { category in
                        Button {
                            selectedCategory = category
                            selectedSubcategory = nil
                        } label: {
                            Text(category)
                                .font(.system(size: 12, weight: .semibold))
                                .fixedSize()
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .foregroundStyle(
                                    selectedCategory == category
                                    ? RestyleColors.primaryActionText
                                    : RestyleColors.textSecondary
                                )
                                .background(
                                    selectedCategory == category
                                    ? RestyleColors.lime
                                    : RestyleColors.surface,
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, RestyleSpacing.screenPadding)
            }
            .padding(.top, 24)
            
            // MARK: - Subcategories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        selectedSubcategory = nil
                    } label: {
                        Text("All")
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(
                                selectedSubcategory == nil
                                ? RestyleColors.primaryActionText
                                : RestyleColors.textPrimary
                            )
                            .background(
                                selectedSubcategory == nil
                                ? RestyleColors.lime
                                : RestyleColors.surface,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                    
                    ForEach(
                        categories[selectedCategory] ?? [],
                        id: \.self
                    ) { subcategory in
                        Button {
                            selectedSubcategory = subcategory
                        } label: {
                            Text(subcategory)
                                .font(.system(size: 11, weight: .medium))
                                .fixedSize()
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .foregroundStyle(
                                    selectedSubcategory == subcategory
                                    ? RestyleColors.primaryActionText
                                    : RestyleColors.textPrimary
                                )
                                .background(
                                    selectedSubcategory == subcategory
                                    ? RestyleColors.lime
                                    : RestyleColors.surface,
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, RestyleSpacing.screenPadding)
            }
            .padding(.top, 12)
            
            // MARK: - Selection Content
            Spacer()
            
            VStack(spacing: 14) {
                Image(systemName: "tshirt")
                    .font(.system(size: 42, weight: .light))
                    .foregroundStyle(RestyleColors.textSecondary)
                
                Text(
                    selectedSubcategory ?? selectedCategory.uppercased()
                )
                .font(RestyleTypography.editorial(24))
                .multilineTextAlignment(.center)
                .foregroundStyle(RestyleColors.textPrimary)
                
                Text(
                    selectedSubcategory == nil
                    ? "Choose a clothing subcategory above to continue."
                    : "Selected: \(selectedSubcategory!)."
                )
                .font(RestyleTypography.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(RestyleColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            // Next step: connect this selection to photo picking.
            Button {
                showGarmentDetails = true
            } label: {
                HStack {
                    Text("CONTINUE")
                        .font(RestyleTypography.headline)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(RestyleColors.primaryActionText)
                .padding(RestyleSpacing.regular)
                .frame(maxWidth: .infinity)
                .background(
                    selectedSubcategory == nil
                    ? RestyleColors.border
                    : RestyleColors.lime,
                    in: RoundedRectangle(cornerRadius: RestyleRadius.card)
                )
            }
            .buttonStyle(.plain)
            .disabled(selectedSubcategory == nil)
            .padding(.horizontal, RestyleSpacing.screenPadding)
            .padding(.bottom, RestyleSpacing.large)
            .navigationDestination(isPresented: $showGarmentDetails) {
                if let subcategory = selectedSubcategory {
                    AddPieceView(
                        category: selectedCategory,
                        subcategory: subcategory
                    )
                }
                
            }
        }
        
    }
}

#Preview {
    NavigationStack {
        WardrobeCategoriesView()
    }
}
