
import SwiftUI

struct MyRepurposePieceDetailsView: View {

    @EnvironmentObject private var wardrobeStore: WardrobeStore

    @Binding var garment: RepurposeGarment

    let onBack: () -> Void
    let onContinue: () -> Void

    @State private var showWardrobe = false

    // MARK: - Category Options

    // Specific garment types used by guides.json
    private let categories = [
        "T-Shirt", "Tank Top", "Shirt", "Blouse",
        "Sweater", "Hoodie", "Jeans", "Pants",
        "Shorts", "Skirt", "Dress", "Jumpsuit",
        "Jacket", "Coat", "Blazer", "Scarf",
        "Hat", "Bag", "Belt", "Sneakers",
        "Boots", "Heels", "Flats", "Sandals"
    ]

    // MARK: - Material Options

    private let materials = [
        "Cotton", "Denim", "Polyester", "Linen",
        "Wool", "Knit", "Silk", "Leather",
        "Nylon", "Mixed", "Other"
    ]

    // MARK: - Selected Wardrobe Garment

    private var selectedWardrobeGarment: Garment? {

        guard let id = garment.wardrobeGarmentID else {
            return nil
        }

        return wardrobeStore.garments.first {
            $0.id == id
        }
    }

    // Prefer the specific garment type.
    private var selectedCategory: String {
        garment.subcategory.isEmpty
            ? garment.category
            : garment.subcategory
    }

    // MARK: - Validation

    private var canContinue: Bool {

        let hasCategory = !selectedCategory
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty

        let hasMaterial = !garment.material
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty

        return hasCategory && hasMaterial
    }

    // MARK: - Body

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            // MARK: Back Button

            Button(action: onBack) {

                Image(systemName: "chevron.left")
                    .font(.system(size: 18))
                    .foregroundStyle(RestyleColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        RestyleColors.surfaceRaised,
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
            .buttonStyle(.plain)

            // MARK: Main Content

            ScrollView {

                VStack(alignment: .leading, spacing: 12) {

                    Text("WHAT'S YOUR\nPIECE?")
                        .font(RestyleTypography.editorial(42))
                        .foregroundStyle(RestyleColors.textPrimary)
                        .padding(.top, 25)

                    Text(
                        "Choose your garment type and material to find a suitable repurpose project."
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(RestyleColors.textSecondary)

                    // MARK: Illustration

                    Image("Repurposeit")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 210)

                    // MARK: Choose From My Wardrobe

                    Button {
                        showWardrobe = true
                    } label: {

                        HStack(spacing: 10) {

                            Image(systemName: "hanger")
                                .font(.system(size: 16))

                            VStack(
                                alignment: .leading,
                                spacing: 3
                            ) {

                                Text(
                                    selectedWardrobeGarment?.name
                                        ?? "Choose from My Wardrobe"
                                )
                                .font(
                                    .system(
                                        size: 13,
                                        weight: .semibold
                                    )
                                )

                                if selectedWardrobeGarment != nil {

                                    Text("Selected wardrobe piece")
                                        .font(.system(size: 11))
                                        .foregroundStyle(
                                            RestyleColors.textSecondary
                                        )
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(
                                    .system(
                                        size: 13,
                                        weight: .semibold
                                    )
                                )
                        }
                        .foregroundStyle(RestyleColors.textPrimary)
                        .padding(14)
                        .background(
                            RestyleColors.lime.opacity(0.16),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                    }
                    .buttonStyle(.plain)

                    // MARK: Category Dropdown

                    dropdown(
                        "Category",
                        selected: selectedCategory,
                        options: categories
                    ) { value in

                        garment.category = value
                        garment.subcategory = value

                        // Manual edits only change Repurpose data.
                        garment.wardrobeGarmentID = nil
                    }

                    // MARK: Material Dropdown

                    dropdown(
                        "Material",
                        selected: garment.material,
                        options: materials
                    ) { value in

                        garment.material = value

                        // Do not modify the original wardrobe item.
                        garment.wardrobeGarmentID = nil
                    }
                }
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 20)

        // MARK: Continue Button

        .safeAreaInset(edge: .bottom) {

            Button(action: onContinue) {

                Text("Continue")
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(RestyleColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        canContinue
                            ? RestyleColors.lime
                            : Color.gray.opacity(0.25),
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canContinue)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(RestyleColors.background)
        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )

        // MARK: Existing My Wardrobe

        .sheet(isPresented: $showWardrobe) {

            NavigationStack {

                MyWardrobeView(
                    onSelectGarment: { saved in

                        // Copy the selected item's information
                        // into our separate Repurpose model.
                        garment = RepurposeGarment(from: saved)

                        // Close the wardrobe sheet.
                        showWardrobe = false
                    }
                )
            }
            .environmentObject(wardrobeStore)
        }
    }

    // MARK: - Reusable Dropdown

    private func dropdown(
        _ title: String,
        selected: String,
        options: [String],
        onSelect: @escaping (String) -> Void
    ) -> some View {

        Menu {

            ForEach(options, id: \.self) { option in

                Button(option) {
                    onSelect(option)
                }
            }

        } label: {

            HStack {

                Text(title)
                    .fontWeight(.medium)

                Spacer()

                Text(
                    selected.isEmpty
                        ? "Select"
                        : selected
                )
                .foregroundStyle(RestyleColors.textSecondary)
                .lineLimit(1)

                Image(systemName: "chevron.down")
                    .font(
                        .system(
                            size: 12,
                            weight: .semibold
                        )
                    )
            }
            .font(.system(size: 14))
            .foregroundStyle(RestyleColors.textPrimary)
            .padding(.horizontal, 16)
            .frame(height: 52)
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
        }
    }
}
