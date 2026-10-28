
import SwiftUI
import PhotosUI

struct RestyleWardrobePickerView: View {

    @EnvironmentObject private var wardrobeStore: WardrobeStore
    @Environment(\.dismiss) private var dismiss

    let onSelect: (Garment, UIImage) -> Void

    @State private var missingPhotoGarment: Garment?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showPhotoError = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("CHOOSE FROM YOUR WARDROBE.")
                    .font(RestyleTypography.editorial(32))
                    .foregroundStyle(RestyleColors.textPrimary)

                Text("Select the piece you want to restyle.")
                    .font(RestyleTypography.body)
                    .foregroundStyle(RestyleColors.textSecondary)

                if wardrobeStore.garments.isEmpty {

                    ContentUnavailableView(
                        "Your Wardrobe Is Empty",
                        systemImage: "hanger",
                        description: Text(
                            "Add a piece to your wardrobe or upload a new photo."
                        )
                    )

                } else {

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(wardrobeStore.garments) { garment in

                            Button {
                                select(garment)
                            } label: {
                                garmentCard(garment)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if let garment = missingPhotoGarment {

                    VStack(alignment: .leading, spacing: 12) {

                        Text("PHOTO REQUIRED")
                            .font(RestyleTypography.headline)

                        Text(
                            "Add a photo of \(garment.name) to use it as your starting piece."
                        )
                        .font(RestyleTypography.body)
                        .foregroundStyle(RestyleColors.textSecondary)

                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images
                        ) {
                            Text("Add Photo")
                                .font(RestyleTypography.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundStyle(.black)
                                .background(RestyleColors.lime)
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .background(RestyleColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(RestyleSpacing.screenPadding)
        }
        .background(RestyleColors.background.ignoresSafeArea())
        .navigationTitle("My Wardrobe")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                await loadMissingPhoto(newPhoto)
            }
        }
        .alert("Photo Error", isPresented: $showPhotoError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The selected photo could not be loaded.")
        }
    }

    private func garmentCard(_ garment: Garment) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            Group {
                if let image = wardrobeStore.image(for: garment) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundStyle(RestyleColors.textSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(height: 170)
            .frame(maxWidth: .infinity)
            .background(RestyleColors.surfaceRaised)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(garment.name)
                .font(RestyleTypography.headline)
                .foregroundStyle(RestyleColors.textPrimary)
                .lineLimit(1)

            Text(garment.category)
                .font(RestyleTypography.subheadline)
                .foregroundStyle(RestyleColors.textSecondary)
        }
    }

    private func select(_ garment: Garment) {
        if let image = wardrobeStore.image(for: garment) {
            onSelect(garment, image)
            dismiss()
        } else {
            missingPhotoGarment = garment
        }
    }

    @MainActor
    private func loadMissingPhoto(
        _ photo: PhotosPickerItem?
    ) async {
        guard let photo,
              let garment = missingPhotoGarment else {
            return
        }

        do {
            guard let data = try await photo.loadTransferable(
                type: Data.self
            ),
            let image = UIImage(data: data) else {
                showPhotoError = true
                return
            }

            onSelect(garment, image)
            dismiss()

        } catch {
            showPhotoError = true
        }
    }
}

