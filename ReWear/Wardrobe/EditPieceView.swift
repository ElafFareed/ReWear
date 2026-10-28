
import SwiftUI

struct EditPieceView: View {

    let garment: Garment

    @EnvironmentObject private var wardrobeStore: WardrobeStore
    @Environment(\.dismiss) private var dismiss

    @State private var editedGarment: Garment
    @State private var showDeleteConfirmation = false

    init(garment: Garment) {
        self.garment = garment
        _editedGarment = State(initialValue: garment)
    }

    // MARK: - Categories

    private let garmentCategories: [String: [String]] = [
        "Tops": [
            "T-Shirts", "Blouses", "Tank Tops", "Sweaters",
            "Cardigans", "Men's T-Shirts", "Men's Casual Shirts",
            "Sweatshirts", "Hoodies"
        ],

        "Bottoms": [
            "Jeans", "Pants", "Shorts", "Skirts",
            "Skinny Jeans", "Boyfriend Jeans",
            "Straight Leg Jeans", "Leggings",
            "Activewear Pants", "Men's Jeans",
            "Men's Casual Pants", "Capri & Cropped Pants"
        ],

        "Dresses & One-Pieces": [
            "Dresses", "Day Dresses", "Cocktail Dresses",
            "Gowns", "Rompers"
        ],

        "Outerwear": [
            "Jackets", "Coats", "Blazers",
            "Vests", "Men's Jackets"
        ],

        "Shoes": [
            "Boots", "Ankle Booties", "Knee High Boots",
            "Over-The-Knee Boots", "Pumps", "Sandals",
            "Flats", "Sneakers", "Men's Sneakers",
            "Loafers & Moccasins", "Oxfords"
        ],

        "Accessories": [
            "Bags", "Handbags", "Tote Bags", "Shoulder Bags",
            "Clutches", "Backpacks", "Messenger Bags",
            "Belts", "Hats", "Men's Hats", "Sunglasses",
            "Men's Sunglasses", "Jewelry", "Watches",
            "Men's Watches", "Necklaces", "Earrings",
            "Rings", "Bracelets & Bangles", "Scarves",
            "Socks", "Gloves", "Hair Accessories"
        ]
    ]

    private let colors = [
        "Not sure", "Black", "White", "Grey", "Beige",
        "Brown", "Blue", "Navy", "Red", "Pink",
        "Green", "Yellow", "Purple", "Orange",
        "Multicolor"
    ]

    private let patterns = [
        "Not sure", "Solid", "Striped", "Floral",
        "Plaid", "Polka Dot", "Graphic",
        "Animal Print", "Other"
    ]

    private let materials = [
        "Not sure", "Cotton", "Denim", "Linen",
        "Wool", "Silk", "Polyester", "Leather",
        "Knit", "Nylon", "Other"
    ]

    // MARK: - Main View

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            navigationHeader

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    headingSection

                    garmentPhoto
                        .padding(.top, 28)

                    editingFields
                        .padding(.top, 35)
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            saveButton
        }
        .padding(.horizontal, RestyleSpacing.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)

        // MARK: - Custom Delete Confirmation
        .sheet(isPresented: $showDeleteConfirmation) {
            RemovePieceSheet(
                garmentName: editedGarment.name,

                onKeep: {
                    showDeleteConfirmation = false
                },

                onRemove: {
                    wardrobeStore.removeGarment(id: garment.id)
                    showDeleteConfirmation = false
                    dismiss()
                }
            )
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(30)
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        HStack {

            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .frame(width: 42, height: 42)
                    .background(
                        RestyleColors.surfaceRaised,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }

            Spacer()

            // Trash button opens custom bottom sheet
            Button {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .frame(width: 42, height: 42)
                    .background(
                        RestyleColors.surfaceRaised,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }
        }
        .foregroundStyle(RestyleColors.textPrimary)
        .padding(.top, 8)
    }

    // MARK: - Heading

    private var headingSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("EDIT YOUR PIECE.")
                .font(RestyleTypography.editorial(30))
                .foregroundStyle(RestyleColors.textPrimary)
                .overlay(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 200, height: 3)
                }

            Text("Update the details saved on this device.")
                .font(RestyleTypography.body)
                .foregroundStyle(RestyleColors.textSecondary)
                .padding(.top, 8)
        }
        .padding(.top, 25)
    }

    // MARK: - Garment Photo

    private var garmentPhoto: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)

            if let image = wardrobeStore.image(for: garment) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            } else {
                Image(systemName: "tshirt")
                    .font(.system(size: 70, weight: .ultraLight))
                    .foregroundStyle(RestyleColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 225)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    RestyleColors.border.opacity(0.5)
                )
        }
    }

    // MARK: - Editing Fields

    private var editingFields: some View {
        VStack(spacing: 12) {

            categoryMenu

            selectionMenu(
                "Color",
                selection: $editedGarment.color,
                options: colors
            )

            selectionMenu(
                "Pattern",
                selection: $editedGarment.pattern,
                options: patterns
            )

            selectionMenu(
                "Material",
                selection: $editedGarment.material,
                options: materials
            )
        }
    }

    // MARK: - Category Menu

    private var categoryMenu: some View {
        Menu {
            ForEach(
                garmentCategories.keys.sorted(),
                id: \.self
            ) { category in

                Menu(category) {
                    ForEach(
                        garmentCategories[category] ?? [],
                        id: \.self
                    ) { subcategory in

                        Button(subcategory) {
                            editedGarment.category = category
                            editedGarment.subcategory = subcategory
                        }
                    }
                }
            }
        } label: {
            fieldRow(
                "Category",
                value: editedGarment.subcategory
            )
        }
    }

    // MARK: - Reusable Selection Menu

    private func selectionMenu(
        _ title: String,
        selection: Binding<String>,
        options: [String]
    ) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selection.wrappedValue =
                        option == "Not sure" ? "" : option
                }
            }
        } label: {
            fieldRow(
                title,
                value: selection.wrappedValue.isEmpty
                    ? "Not sure"
                    : selection.wrappedValue
            )
        }
    }

    // MARK: - Reusable Field Row

    private func fieldRow(
        _ title: String,
        value: String
    ) -> some View {
        HStack(spacing: 10) {

            Text(title)
                .font(.system(size: 14, weight: .medium))

            Spacer()

            Text(value)
                .font(.system(size: 13))
                .foregroundStyle(RestyleColors.textSecondary)
                .lineLimit(1)

            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(RestyleColors.textPrimary)
        .padding(.horizontal, 16)
        .frame(height: 58)
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    RestyleColors.border.opacity(0.5)
                )
        }
        .contentShape(Rectangle())
    }

    // MARK: - Save Changes

    private var saveButton: some View {
        Button {

            wardrobeStore.updateGarment(editedGarment)
            dismiss()

        } label: {
            Text("Save Changes")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(RestyleColors.primaryActionText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RestyleColors.lime,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .padding(.bottom, 20)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EditPieceView(
            garment: Garment(
                name: "Black jacket",
                category: "Outerwear",
                subcategory: "Jackets"
            )
        )
    }
    .environmentObject(WardrobeStore())
}

