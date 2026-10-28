
import SwiftUI
import PhotosUI

struct AddPieceView: View {

    // MARK: - Input
    let category: String
    let subcategory: String

    // MARK: - Environment
    @EnvironmentObject private var wardrobeStore: WardrobeStore
    @Environment(\.dismiss) private var dismiss

    // MARK: - Photo State
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var garmentImage: UIImage?

    // MARK: - Category State
    @State private var selectedCategory: String
    @State private var selectedSubcategory: String

    // MARK: - Alert State
    @State private var showSaveNotice = false
    @State private var saveError: String?

    init(category: String, subcategory: String) {
        self.category = category
        self.subcategory = subcategory

        _selectedCategory = State(initialValue: category)
        _selectedSubcategory = State(initialValue: subcategory)
    }

    // MARK: - Categories
    private let categories: [String: [String]] = [
        "Tops": [
            "T-Shirts", "Blouses", "Tank Tops", "Sweaters",
            "Cardigans", "Men's T-Shirts", "Men's Casual Shirts",
            "Sweatshirts", "Hoodies"
        ],

        "Bottoms": [
            "Jeans", "Pants", "Shorts", "Skirts", "Skinny Jeans",
            "Boyfriend Jeans", "Straight Leg Jeans", "Leggings",
            "Activewear Pants", "Men's Jeans",
            "Men's Casual Pants", "Capri & Cropped Pants"
        ],

        "Dresses & One-Pieces": [
            "Dresses", "Day Dresses", "Cocktail Dresses",
            "Gowns", "Rompers"
        ],

        "Outerwear": [
            "Jackets", "Coats", "Blazers", "Vests",
            "Men's Jackets"
        ],

        "Shoes": [
            "Boots", "Ankle Booties", "Knee High Boots",
            "Over-The-Knee Boots", "Pumps", "Sandals",
            "Flats", "Sneakers", "Men's Sneakers",
            "Loafers & Moccasins", "Oxfords"
        ],

        "Accessories": [
            "Bags", "Handbags", "Tote Bags", "Shoulder Bags",
            "Clutches", "Backpacks", "Messenger Bags", "Belts",
            "Hats", "Men's Hats", "Sunglasses", "Men's Sunglasses",
            "Jewelry", "Watches", "Men's Watches", "Necklaces",
            "Earrings", "Rings", "Bracelets & Bangles",
            "Scarves", "Socks", "Gloves", "Hair Accessories"
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

    // MARK: - Validation
    private var canAdd: Bool {
        guard let options = categories[selectedCategory] else {
            return false
        }

        return options.contains(selectedSubcategory)
    }

    // MARK: - Main Screen
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            navigationHeader

            ScrollView {
                formContent
            }
            .scrollIndicators(.hidden)

            addButton
        }
        .padding(.horizontal, RestyleSpacing.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                await loadPhoto(newPhoto)
            }
        }
        .alert("Piece added!", isPresented: $showSaveNotice) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your piece has been saved to My Wardrobe.")
        }
        .alert(
            "Could not save piece",
            isPresented: Binding<Bool>(
                get: { saveError != nil },
                set: { isPresented in
                    if !isPresented {
                        saveError = nil
                    }
                }
            )
        ) {
            Button("OK") {
                saveError = nil
            }
        } message: {
            Text(saveError ?? "An unknown error occurred.")
        }
    }

    // MARK: - Navigation Header
    private var navigationHeader: some View {
        HStack {

            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 34, height: 34)
                    .background(
                        RestyleColors.surfaceRaised,
                        in: RoundedRectangle(cornerRadius: 10)
                    )
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 34, height: 34)
                    .background(
                        RestyleColors.surfaceRaised,
                        in: RoundedRectangle(cornerRadius: 10)
                    )
            }
        }
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(RestyleColors.textPrimary)
        .padding(.top, 8)
    }

    // MARK: - Form Content
    private var formContent: some View {
        VStack(alignment: .leading, spacing: 0) {

            headingSection

            photoUploadSection

            categorySelectionSection

            subcategorySelectionSection
        }
        .padding(.bottom, 24)
    }

    // MARK: - Heading
    private var headingSection: some View {
        Text("ADD YOUR PIECE.")
            .font(RestyleTypography.editorial(25))
            .foregroundStyle(RestyleColors.textPrimary)
            .padding(.top, 34)
    }

    // MARK: - Photo Upload
    private var photoUploadSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Add a piece")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RestyleColors.textPrimary)

            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images
            ) {
                photoPreview
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .background(
                        Color.white,
                        in: RoundedRectangle(cornerRadius: 15)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 35)
    }

    // MARK: - Photo Preview
    private var photoPreview: some View {
        VStack(spacing: 8) {

            if let garmentImage {
                Image(uiImage: garmentImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 115)

            } else {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 24))
                    .foregroundStyle(RestyleColors.textSecondary)
                    .frame(width: 46, height: 46)
                    .background(
                        RestyleColors.surfaceRaised,
                        in: Circle()
                    )

                Text("Upload a photo")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RestyleColors.textPrimary)

                Text("Choose a photo of the clothing item.")
                    .font(.system(size: 10))
                    .foregroundStyle(RestyleColors.textSecondary)
            }
        }
    }

    // MARK: - Category Selection
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Choose garment details")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RestyleColors.textPrimary)
                .padding(.bottom, 12)

            Text("Category")
                .font(.system(size: 11))
                .foregroundStyle(RestyleColors.textSecondary)

            Menu {
                ForEach(categoryOrder, id: \.self) { option in
                    Button(option) {
                        selectedCategory = option
                        selectedSubcategory = ""
                    }
                }
            } label: {
                dropdownLabel(
                    selectedCategory.isEmpty
                    ? "Choose category"
                    : selectedCategory
                )
            }
        }
        .padding(.top, 24)
    }

    // MARK: - Subcategory Selection
    private var subcategorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Subcategory")
                .font(.system(size: 11))
                .foregroundStyle(RestyleColors.textSecondary)

            Menu {
                ForEach(
                    categories[selectedCategory] ?? [],
                    id: \.self
                ) { option in
                    Button(option) {
                        selectedSubcategory = option
                    }
                }
            } label: {
                dropdownLabel(
                    selectedSubcategory.isEmpty
                    ? "Choose subcategory"
                    : selectedSubcategory
                )
            }
            .disabled(selectedCategory.isEmpty)
        }
        .padding(.top, 16)
    }

    // MARK: - Reusable Dropdown Design
    private func dropdownLabel(_ title: String) -> some View {
        HStack {
            Text(title)

            Spacer()

            Image(systemName: "chevron.down")
        }
        .font(.system(size: 12))
        .foregroundStyle(RestyleColors.textPrimary)
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 12)
        )
    }

    // MARK: - Add Button
    private var addButton: some View {
        Button {
            savePiece()
        } label: {
            Text("Add")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RestyleColors.primaryActionText)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    canAdd
                    ? RestyleColors.lime
                    : RestyleColors.border,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .disabled(!canAdd)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

    // MARK: - Save Piece
    private func savePiece() {
        guard canAdd else {
            return
        }

        do {
            try wardrobeStore.addGarment(
                category: selectedCategory,
                subcategory: selectedSubcategory,
                image: garmentImage
            )

            showSaveNotice = true

        } catch {
            saveError = error.localizedDescription
        }
    }

    // MARK: - Load Photo
    @MainActor
    private func loadPhoto(
        _ photo: PhotosPickerItem?
    ) async {
        guard let photo else {
            garmentImage = nil
            return
        }

        do {
            if let data = try await photo.loadTransferable(
                type: Data.self
            ) {
                garmentImage = UIImage(data: data)
            }
        } catch {
            saveError = "Could not load the selected photo."
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AddPieceView(
            category: "Tops",
            subcategory: "T-Shirts"
        )
    }
    .environmentObject(WardrobeStore())
}

