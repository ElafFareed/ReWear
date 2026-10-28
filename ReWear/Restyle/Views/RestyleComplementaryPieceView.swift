import SwiftUI
import PhotosUI

struct RestyleComplementaryPieceView: View {

    @Environment(\.dismiss) private var dismiss

    let selectedItem: String

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var garmentImage: UIImage?

    @State private var itemDescription = ""
    @State private var showPhotoError = false
    @State private var showNextStepNotice = false

    var body: some View {
        VStack(spacing: 0) {

            header

            progressBar

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    titleSection

                    uploadSection

                    manualSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 45)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            continueButton
        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                await loadPhoto(newPhoto)
            }
        }
        .alert(
            "Photo Error",
            isPresented: $showPhotoError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We couldn't load that photo. Please try again.")
        }
        .alert(
            "Piece confirmed",
            isPresented: $showNextStepNotice
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "Your \(selectedItem.lowercased()) are ready for the next Restyle step. Compatibility scoring has not run yet."
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {

            Button {
                dismiss()
            } label: {
                headerIcon("chevron.left")
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                headerIcon("xmark")
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    private func headerIcon(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(RestyleColors.textPrimary)
            .frame(width: 48, height: 48)
            .background(
                Color(hex: 0xF2F1F3),
                in: RoundedRectangle(cornerRadius: 16)
            )
    }

    // MARK: - Progress

    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(
                        index < 2
                        ? RestyleColors.coral
                        : Color(hex: 0xCAC9CC)
                    )
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("CHOOSE YOUR\nPIECE.")
                .font(RestyleTypography.editorial(42))
                .foregroundStyle(RestyleColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(
                "Add your \(selectedItem.lowercased()) to complete your look."
            )
            .font(RestyleTypography.body)
            .foregroundStyle(RestyleColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Upload Photo

    private var uploadSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Add a piece")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(RestyleColors.textSecondary)

            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images,
                photoLibrary: .shared()
            ) {
                VStack(spacing: 14) {

                    if let garmentImage {

                        Image(uiImage: garmentImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 165)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )

                        Text("Photo uploaded")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(RestyleColors.textPrimary)

                        Text("Tap to change the photo")
                            .font(.system(size: 14))
                            .foregroundStyle(RestyleColors.textSecondary)

                    } else {

                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 28))
                            .foregroundStyle(Color(hex: 0xA5A5A5))
                            .frame(width: 68, height: 68)
                            .background(
                                Color(hex: 0xE9E9EB),
                                in: Circle()
                            )

                        Text("Upload a photo")
                            .font(.system(size: 19))
                            .foregroundStyle(RestyleColors.textSecondary)

                        Text("Choose a photo of your clothing item.")
                            .font(.system(size: 15))
                            .foregroundStyle(RestyleColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 200)
                .padding(16)
                .background(
                    Color.white,
                    in: RoundedRectangle(cornerRadius: 24)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            Color(hex: 0xE8E8E8),
                            lineWidth: 1
                        )
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Manual Description

    private var manualSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Describe it manually")
                .font(RestyleTypography.body)
                .foregroundStyle(RestyleColors.textSecondary)

            HStack(spacing: 12) {

                TextField(
                    "e.g. Black \(selectedItem.lowercased())",
                    text: $itemDescription
                )
                .font(RestyleTypography.body)
                .foregroundStyle(RestyleColors.textPrimary)
                .textInputAutocapitalization(.sentences)

                Image(systemName: "pencil")
                    .foregroundStyle(RestyleColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .frame(height: 82)
            .background(
                Color.white,
                in: RoundedRectangle(cornerRadius: 22)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        Color(hex: 0xE8E8E8),
                        lineWidth: 1
                    )
            }
        }
    }

    // MARK: - Continue

    private var continueButton: some View {
        Button {
            // Photo remains optional on this screen.
            // No Core ML scoring happens here.
            showNextStepNotice = true

        } label: {
            Text("Continue")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RestyleColors.lime,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(RestyleColors.background)
    }

    // MARK: - Load Photo

    @MainActor
    private func loadPhoto(_ photo: PhotosPickerItem?) async {

        guard let photo else { return }

        do {
            guard let data = try await photo.loadTransferable(
                type: Data.self
            ),
            let image = UIImage(data: data) else {
                showPhotoError = true
                return
            }

            garmentImage = image

        } catch {
            showPhotoError = true
        }
    }
}

#Preview {
    NavigationStack {
        RestyleComplementaryPieceView(
            selectedItem: "Trousers"
        )
    }
}

