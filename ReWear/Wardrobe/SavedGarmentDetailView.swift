
import SwiftUI

struct SavedGarmentDetailView: View {

    let garment: Garment

    @EnvironmentObject private var wardrobeStore: WardrobeStore
    @Environment(\.dismiss) private var dismiss

    @State private var showStyleNotice = false

    // MARK: - Latest Saved Garment
    private var currentGarment: Garment {
        wardrobeStore.garments.first {
            $0.id == garment.id
        } ?? garment
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            navigationHeader

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    Text("SAVED GARMENT")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(RestyleColors.textSecondary)
                        .padding(.top, 30)

                    Text(currentGarment.name.uppercased() + ".")
                        .font(RestyleTypography.editorial(32))
                        .foregroundStyle(RestyleColors.textPrimary)
                        .padding(.top, 22)

                    garmentPhoto
                        .padding(.top, 24)

                    garmentInformation
                        .padding(.top, 55)
                }
                .padding(.bottom, 25)
            }
            .scrollIndicators(.hidden)

            styleButton
        }
        .padding(.horizontal, RestyleSpacing.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)

        // Close details if garment is removed
        .onChange(of: wardrobeStore.garments.map(\.id)) {
            _, ids in

            if !ids.contains(garment.id) {
                dismiss()
            }
        }

        // Restyle connection will be added later
        .alert(
            "Style This Piece",
            isPresented: $showStyleNotice
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "We'll connect this saved garment to the Restyle flow next."
            )
        }
    }

    // MARK: - Navigation
    private var navigationHeader: some View {
        HStack {

            // Back button
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15))
                    .frame(width: 40, height: 40)
                    .background(
                        RestyleColors.surfaceRaised,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }

            Spacer()

            // Edit button
            NavigationLink {
                EditPieceView(garment: currentGarment)
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 17))
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

    // MARK: - Garment Photo
    private var garmentPhoto: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)

            if let image = wardrobeStore.image(
                for: currentGarment
            ) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            } else {
                Image(systemName: "tshirt")
                    .font(
                        .system(
                            size: 75,
                            weight: .ultraLight
                        )
                    )
                    .foregroundStyle(
                        RestyleColors.textSecondary
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    RestyleColors.border.opacity(0.5)
                )
        }
    }

    // MARK: - Garment Information
    private var garmentInformation: some View {
        VStack(spacing: 20) {

            detailRow(
                "CATEGORY",
                value: currentGarment.subcategory
            )

            detailRow(
                "COLOR",
                value: currentGarment.color
            )

            detailRow(
                "PATTERN",
                value: currentGarment.pattern
            )

            detailRow(
                "MATERIAL",
                value: currentGarment.material
            )
        }
        .padding(18)
        .frame(maxWidth: .infinity)
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

    // MARK: - Reusable Detail Row
    private func detailRow(
        _ title: String,
        value: String
    ) -> some View {
        HStack(alignment: .firstTextBaseline) {

            Text(title)
                .font(
                    .system(
                        size: 12,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    RestyleColors.textSecondary
                )

            Spacer()

            Text(
                value.isEmpty
                ? "Not sure"
                : value
            )
            .font(
                .system(
                    size: 12,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                RestyleColors.textPrimary
            )
            .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Style Button
    private var styleButton: some View {
        Button {
            showStyleNotice = true
        } label: {
            Text("Style This Piece")
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RestyleColors.primaryActionText
                )
                .frame(maxWidth: .infinity)
                .frame(height: 50)
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
        SavedGarmentDetailView(
            garment: Garment(
                name: "Black jacket",
                category: "Outerwear",
                subcategory: "Jackets"
            )
        )
    }
    .environmentObject(WardrobeStore())
}

