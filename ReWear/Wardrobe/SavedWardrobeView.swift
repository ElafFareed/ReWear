
import SwiftUI

struct SavedWardrobeView: View {

    @EnvironmentObject private var wardrobeStore: WardrobeStore
    @Environment(\.dismiss) private var dismiss

    // When nil, the wardrobe works normally.
    // When provided, tapping a garment selects it.
    var onSelectGarment: ((Garment) -> Void)? = nil

    @State private var searchText = ""
    @State private var selectedCategory = "All"

    private let categories = [
        "All",
        "Tops",
        "Bottoms",
        "Outerwear",
        "Dresses & One-Pieces",
        "Shoes",
        "Accessories"
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // MARK: - Filter Saved Clothes

    private var filteredGarments: [Garment] {

        wardrobeStore.garments.filter { garment in

            let matchesCategory =
                selectedCategory == "All" ||
                garment.category == selectedCategory

            let matchesSearch =
                searchText.isEmpty ||
                garment.name.localizedCaseInsensitiveContains(searchText) ||
                garment.subcategory.localizedCaseInsensitiveContains(searchText)

            return matchesCategory && matchesSearch
        }
    }

    // MARK: - Body

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            navigationHeader

            Text("MY WARDROBE.")
                .font(RestyleTypography.editorial(32))
                .foregroundStyle(RestyleColors.textPrimary)
                .padding(.top, 24)

            Text(
                onSelectGarment == nil
                    ? "Ready for more looks."
                    : "Choose a piece to repurpose."
            )
            .font(RestyleTypography.body)
            .foregroundStyle(RestyleColors.textSecondary)
            .padding(.top, 8)

            searchBar
                .padding(.top, 34)

            categoryFilters
                .padding(.top, 14)

            ScrollView {

                if filteredGarments.isEmpty {

                    ContentUnavailableView(
                        "No matching pieces",
                        systemImage: "magnifyingglass",
                        description: Text(
                            "Try another search or category."
                        )
                    )
                    .padding(.top, 40)

                } else {

                    LazyVGrid(
                        columns: columns,
                        spacing: 12
                    ) {

                        ForEach(filteredGarments) { garment in
                            garmentCard(garment)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, RestyleSpacing.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {

        HStack {

            Button {
                dismiss()
            } label: {

                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 40, height: 40)
                    .background(
                        RestyleColors.surfaceRaised,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            NavigationLink {
                WardrobeCategoriesView()
            } label: {

                Image(systemName: "plus.square")
                    .font(.system(size: 23))
                    .frame(width: 40, height: 40)
                    .background(
                        RestyleColors.surfaceRaised,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(RestyleColors.textPrimary)
        .padding(.top, 8)
    }

    // MARK: - Search Bar

    private var searchBar: some View {

        HStack(spacing: 12) {

            Image(systemName: "magnifyingglass")
                .foregroundStyle(RestyleColors.textSecondary)

            TextField(
                "Search saved clothes",
                text: $searchText
            )
            .font(.system(size: 13))
            .autocorrectionDisabled()
        }
        .padding(16)
        .background(
            Color.white,
            in: Capsule()
        )
        .overlay {
            Capsule()
                .strokeBorder(RestyleColors.border)
        }
    }

    // MARK: - Category Filters

    private var categoryFilters: some View {

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {

            HStack(spacing: 8) {

                ForEach(categories, id: \.self) { category in

                    Button {
                        selectedCategory = category
                    } label: {

                        Text(category)
                            .font(
                                .system(
                                    size: 12,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(
                                RestyleColors.textPrimary
                            )
                            .padding(.horizontal, 16)
                            .frame(height: 36)
                            .background(
                                selectedCategory == category
                                    ? RestyleColors.lime
                                    : Color.white,
                                in: Capsule()
                            )
                            .overlay {
                                Capsule()
                                    .strokeBorder(
                                        RestyleColors.border.opacity(0.5)
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Garment Card

    @ViewBuilder
    private func garmentCard(
        _ garment: Garment
    ) -> some View {

        if let onSelectGarment {

            // Repurpose mode:
            // Select garment instead of opening details.

            Button {
                onSelectGarment(garment)
            } label: {
                garmentCardContent(garment)
            }
            .buttonStyle(.plain)

        } else {

            // Normal wardrobe mode:
            // Open the garment detail screen.

            NavigationLink {
                SavedGarmentDetailView(
                    garment: garment
                )
            } label: {
                garmentCardContent(garment)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Shared Garment Card Design

    private func garmentCardContent(
        _ garment: Garment
    ) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            Group {

                if let image = wardrobeStore.image(
                    for: garment
                ) {

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()

                } else {

                    Image(systemName: "tshirt")
                        .resizable()
                        .scaledToFit()
                        .padding(30)
                        .foregroundStyle(
                            RestyleColors.textSecondary
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(
                RestyleColors.surfaceRaised
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )

            Text(garment.name)
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RestyleColors.textPrimary
                )
                .lineLimit(1)

            Text(garment.category)
                .font(.system(size: 11))
                .foregroundStyle(
                    RestyleColors.textSecondary
                )
        }
        .padding(10)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 15)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(
                    RestyleColors.border.opacity(0.5)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SavedWardrobeView()
    }
    .environmentObject(WardrobeStore())
}

