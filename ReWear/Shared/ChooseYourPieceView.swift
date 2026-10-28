import SwiftUI
import PhotosUI
import UIKit

// MARK: - Piece Source

private enum PieceSource {
    case wardrobe
    case photo
}

// MARK: - Choose Your Piece

struct ChooseYourPieceView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.rewearReturnHome) private var returnHome
    @EnvironmentObject private var wardrobeStore: WardrobeStore

    // Selected photo
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var startingImage: UIImage?

    // Selected garment
    @State private var selectedGarment: Garment?
    @State private var selectedSource: PieceSource?

    // User-selected OCMCF category
    @State private var selectedCategory: String?

    // Navigation
    @State private var showWardrobePicker = false
    @State private var showPieceAdded = false
    @State private var showPhotoError = false
    @State private var showLeaveConfirmation = false
    @State private var shouldReturnHome = false

    // MARK: - Validation

    private var canContinue: Bool {
        startingImage != nil && selectedCategory != nil
    }

    private var selectedPieceName: String {
        if selectedSource == .wardrobe {
            return selectedGarment?.name ?? "Your piece"
        }

        switch selectedCategory {
        case "tops":
            return "Top"
        case "bottoms":
            return "Bottom"
        default:
            return "Your uploaded piece"
        }
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            header

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 26
                ) {

                    progressBar

                    titleSection

                    wardrobeSection

                    orDivider

                    uploadSection

                    // Category appears only after a piece
                    // has been selected or uploaded.
                    if startingImage != nil {
                        categorySection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            continueButton
        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)

        // MARK: - Wardrobe Picker

        .sheet(isPresented: $showWardrobePicker) {

            NavigationStack {

                RestyleWardrobePickerView { garment, image in

                    selectedGarment = garment
                    startingImage = image

                    selectedSource = .wardrobe
                    selectedPhoto = nil

                    // Ask the user to confirm the category.
                    selectedCategory = nil
                }
            }
            .environmentObject(wardrobeStore)
        }

        // MARK: - Piece Added Navigation

        .navigationDestination(
            isPresented: $showPieceAdded
        ) {

            if let category = selectedCategory {

                RestylePieceAddedView(
                    pieceName: selectedPieceName,
                    pieceImage: startingImage,
                    startingGarment: selectedGarment,
                    selectedCategory: category
                )
            }
        }

        // MARK: - Photo Selection

        .onChange(of: selectedPhoto) { _, photo in

            guard photo != nil else {
                return
            }

            Task {
                await loadPhoto(photo)
            }
        }

        // MARK: - Photo Error

        .alert(
            "Photo Error",
            isPresented: $showPhotoError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "The selected photo could not be loaded."
            )
        }

        // MARK: - Leave Challenge

        .sheet(
            isPresented: $showLeaveConfirmation,
            onDismiss: {

                if shouldReturnHome {
                    shouldReturnHome = false
                    returnHome()
                }
            }
        ) {
            RestyleLeaveChallengeSheet {

                shouldReturnHome = true
                showLeaveConfirmation = false
            }
            .presentationDetents([.height(390)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(28)
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
                showLeaveConfirmation = true
            } label: {
                headerIcon("xmark")
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    private func headerIcon(
        _ symbol: String
    ) -> some View {

        Image(systemName: symbol)
            .font(
                .system(
                    size: 20,
                    weight: .medium
                )
            )
            .foregroundStyle(
                RestyleColors.textPrimary
            )
            .frame(width: 48, height: 48)
            .background(
                Color(hex: 0xF2F1F3),
                in: RoundedRectangle(cornerRadius: 16)
            )
    }

    // MARK: - Progress Bar

    private var progressBar: some View {

        HStack(spacing: 8) {

            ForEach(0..<3, id: \.self) { index in

                Capsule()
                    .fill(
                        index == 0
                        ? RestyleColors.coral
                        : Color(hex: 0xCAC9CC)
                    )
                    .frame(height: 5)
            }
        }
    }

    // MARK: - Title

    private var titleSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("Choose your\nstarting piece")
                .font(
                    RestyleTypography.editorial(40)
                )
                .foregroundStyle(
                    RestyleColors.textPrimary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(
                "Pick a piece you own to create different looks."
            )
            .font(RestyleTypography.body)
            .foregroundStyle(
                RestyleColors.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .padding(.top, 22)
    }

    // MARK: - Choose from My Wardrobe

    private var wardrobeSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("Choose from My Wardrobe")
                .font(RestyleTypography.body)
                .foregroundStyle(
                    RestyleColors.textSecondary
                )
                .padding(.leading, 6)

            Button {

                showWardrobePicker = true

            } label: {

                HStack(spacing: 12) {

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(
                            selectedSource == .wardrobe
                            ? selectedPieceName
                            : "Choose a piece you already own"
                        )
                        .font(RestyleTypography.body)
                        .foregroundStyle(
                            RestyleColors.textSecondary
                        )

                        if selectedSource == .wardrobe {

                            Text("Piece selected")
                                .font(.system(size: 12))
                                .foregroundStyle(
                                    RestyleColors.textPrimary
                                )
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            RestyleColors.textPrimary
                        )
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 94)
                .background(
                    Color.white,
                    in: RoundedRectangle(
                        cornerRadius: 22
                    )
                )
                .overlay {

                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            Color(hex: 0xE8E8E8),
                            lineWidth: 1
                        )
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - OR Divider

    private var orDivider: some View {

        HStack(spacing: 16) {

            Rectangle()
                .fill(Color(hex: 0xDDDDDD))
                .frame(height: 1)

            Text("OR")
                .font(
                    .system(
                        size: 13,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RestyleColors.textSecondary
                )

            Rectangle()
                .fill(Color(hex: 0xDDDDDD))
                .frame(height: 1)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Upload Photo

    private var uploadSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("Add a piece")
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RestyleColors.textSecondary
                )
                .padding(.leading, 6)

            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images,
                photoLibrary: .shared()
            ) {

                VStack(spacing: 14) {

                    if selectedSource == .photo,
                       let image = startingImage {

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 12
                                )
                            )

                        Text("Photo added")
                            .font(RestyleTypography.body)
                            .foregroundStyle(
                                RestyleColors.textPrimary
                            )

                        Text("Tap to change the photo.")
                            .font(.system(size: 13))
                            .foregroundStyle(
                                RestyleColors.textSecondary
                            )

                    } else {

                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 27))
                            .foregroundStyle(
                                Color(hex: 0xA5A5A5)
                            )
                            .frame(
                                width: 68,
                                height: 68
                            )
                            .background(
                                Color(hex: 0xE9E9EB),
                                in: Circle()
                            )

                        Text("Upload a photo")
                            .font(.system(size: 19))
                            .foregroundStyle(
                                RestyleColors.textSecondary
                            )

                        Text(
                            "Choose a photo of the clothing item."
                        )
                        .font(.system(size: 15))
                        .foregroundStyle(
                            RestyleColors.textSecondary
                        )
                        .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 188)
                .padding(16)
                .background(
                    Color.white,
                    in: RoundedRectangle(
                        cornerRadius: 24
                    )
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

    // MARK: - Choose Category

    private var categorySection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("Choose the category of your piece")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    RestyleColors.textPrimary
                )

            Text(
                "Select the category so we can find a complementary garment."
            )
            .font(.system(size: 13))
            .foregroundStyle(
                RestyleColors.textSecondary
            )

            categoryRow(
                title: "Tops",
                description: "T-shirts, blouses, sweaters, hoodies",
                category: "tops"
            )

            categoryRow(
                title: "Bottoms",
                description: "Jeans, skirts, trousers, shorts",
                category: "bottoms"
            )
        }
    }

    // MARK: - Category Row

    private func categoryRow(
        title: String,
        description: String,
        category: String
    ) -> some View {

        let isSelected = selectedCategory == category

        return Button {

            selectedCategory = category

        } label: {

            HStack(spacing: 14) {

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text(title)
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            RestyleColors.textPrimary
                        )

                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(
                            RestyleColors.textSecondary
                        )
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(
                    systemName: isSelected
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .font(.system(size: 24))
                .foregroundStyle(
                    isSelected
                    ? RestyleColors.lime
                    : Color(hex: 0xCAC9CC)
                )
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                Color.white,
                in: RoundedRectangle(
                    cornerRadius: 18
                )
            )
            .overlay {

                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected
                        ? RestyleColors.lime
                        : Color(hex: 0xE8E8E8),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Continue Button

    private var continueButton: some View {

        Button {

            guard canContinue else {
                return
            }

            showPieceAdded = true

        } label: {

            Text("Continue")
                .font(
                    .system(
                        size: 19,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    canContinue
                    ? Color.black
                    : RestyleColors.textSecondary
                )
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .background(
                    canContinue
                    ? RestyleColors.lime
                    : Color(hex: 0xEFEFEA),
                    in: Capsule()
                )
        }
        .disabled(!canContinue)
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(RestyleColors.background)
    }

    // MARK: - Load Photo

    @MainActor
    private func loadPhoto(
        _ photo: PhotosPickerItem?
    ) async {

        guard let photo else {
            return
        }

        do {

            guard let data =
                try await photo.loadTransferable(
                    type: Data.self
                ),
                let image = UIImage(data: data) else {

                showPhotoError = true
                return
            }

            startingImage = image
            selectedGarment = nil
            selectedSource = .photo

            // A new photo requires category selection.
            selectedCategory = nil

        } catch {

            showPhotoError = true
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChooseYourPieceView()
            .environmentObject(WardrobeStore())
    }
}
