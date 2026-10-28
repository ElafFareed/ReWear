import SwiftUI
import UIKit

struct RestylePieceAddedView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.rewearReturnHome) private var returnHome
    @EnvironmentObject private var wardrobeStore: WardrobeStore

    // MARK: - Starting Piece

    let pieceName: String
    let pieceImage: UIImage?
    var startingGarment: Garment? = nil

    // Category selected by user
    let selectedCategory: String

    // MARK: - State

    @State private var isScoring = false

    @State private var recommendedPieces:
        [OCMCFRecommendation] = []

    @State private var scoreError: String?
    @State private var showOwnership = false

    @State private var showLeaveConfirmation = false
    @State private var shouldReturnHome = false

    // MARK: - Best Recommendation

    private var bestRecommendation: OCMCFRecommendation? {
        recommendedPieces.first
    }

    private var canContinue: Bool {
        bestRecommendation != nil && !isScoring
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            header

            progressBar

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 18
                ) {

                    Text("Piece added!")
                        .font(
                            RestyleTypography.editorial(42)
                        )
                        .foregroundStyle(
                            RestyleColors.textPrimary
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )

                    // Figma Illustration

                    Image("finished")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .accessibilityHidden(true)

                    Text(
                        "Your piece is ready for a new look!"
                    )
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        RestyleColors.textPrimary
                    )
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                    Text(
                        "Let's find a complementary piece for your outfit."
                    )
                    .font(RestyleTypography.body)
                    .foregroundStyle(
                        RestyleColors.textSecondary
                    )
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                    // Model runs without displaying
                    // the recommended garment here.

                    if isScoring {

                        ProgressView()
                            .tint(Color(hex: 0x4478FF))
                            .padding(.top, 16)
                            .frame(maxWidth: .infinity)

                        Text("Preparing your next step...")
                            .font(.system(size: 13))
                            .foregroundStyle(
                                RestyleColors.textSecondary
                            )
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)

                    } else if let scoreError {

                        Text(scoreError)
                            .font(.system(size: 13))
                            .foregroundStyle(
                                RestyleColors.textSecondary
                            )
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            continueButton
        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)

        // MARK: - Ownership Navigation

        .navigationDestination(
            isPresented: $showOwnership
        ) {

            if let recommendation = bestRecommendation {

                RestyleOwnershipView(
                    suggestedItem: recommendation.garment.name,
                    startingPiece: pieceName,
                    recommendations: recommendedPieces
                )
            }
        }

        // MARK: - Run OCMCF

        .task(id: selectedCategory) {
            await findRecommendation()
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
        _ name: String
    ) -> some View {

        Image(systemName: name)
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

    // MARK: - Continue

    private var continueButton: some View {

        Button {

            guard canContinue else {
                return
            }

            showOwnership = true

        } label: {

            Text(
                isScoring
                ? "Preparing..."
                : "Continue"
            )
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
            .frame(height: 60)
            .background(
                canContinue
                ? RestyleColors.lime
                : Color(hex: 0xEFEFEA),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .disabled(!canContinue)
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }

    // MARK: - Real OCMCF Recommendation

    @MainActor
    private func findRecommendation() async {

        recommendedPieces = []
        scoreError = nil
        isScoring = true

        // STEP 1: Get the starting garment image

        let selectedImage: UIImage? = pieceImage ?? {
            guard let startingGarment else {
                return nil
            }

            return wardrobeStore.image(
                for: startingGarment
            )
        }()

        guard let selectedImage else {

            scoreError =
                "Please select a garment with a photo."

            isScoring = false
            return
        }

        // STEP 2: Use the actual selected category

        guard selectedCategory == "tops" ||
              selectedCategory == "bottoms" else {

            scoreError =
                "Please choose Tops or Bottoms."

            isScoring = false
            return
        }

        print("===== SELECTED GARMENT =====")
        print("Piece:", pieceName)
        print("Category:", selectedCategory)
        print("============================")

        // STEP 3: Load the offline OCMCF catalog

        do {

            let service =
                RestyleOCMCFRecommendationService.shared

            if service.catalog.isEmpty {
                try service.loadCatalog()
            }

        } catch {

            scoreError = """
            Could not load the offline garment catalog:
            \(error.localizedDescription)
            """

            isScoring = false
            return
        }

        // STEP 4: Run Core ML inference

        let category = selectedCategory

        let results: Result<
            [OCMCFRecommendation],
            Error
        > = await withCheckedContinuation { continuation in

            DispatchQueue.global(
                qos: .userInitiated
            ).async {

                do {

                    let engine =
                        OCMCFRecommendationEngine.shared

                    let ranked: [OCMCFRecommendation]

                    if category == "bottoms" {

                        // Bottom -> Top recommendations

                        ranked = try engine.recommendTops(
                            forImage: selectedImage,
                            limit: 5
                        )

                    } else {

                        // Top -> Outerwear recommendations

                        ranked = try engine.recommendOuterwear(
                            forImage: selectedImage,
                            limit: 5
                        )
                    }

                    continuation.resume(
                        returning: .success(ranked)
                    )

                } catch {

                    continuation.resume(
                        returning: .failure(error)
                    )
                }
            }
        }

        guard !Task.isCancelled else {
            isScoring = false
            return
        }

        // STEP 5: Save the real ranked results

        switch results {

        case .success(let ranked):

            recommendedPieces = ranked

            if ranked.isEmpty {

                scoreError =
                    "No complementary pieces were found."

            } else if let best = ranked.first {

                print("===== OCMCF RECOMMENDATIONS =====")
                print("Starting piece:", pieceName)
                print("Starting category:", category)
                print("Recommended:", best.garment.name)
                print("Score:", best.score)

                print("Alternative recommendations:")

                for (index, result) in ranked.dropFirst().enumerated() {

                    print(
                        "\(index + 2).",
                        result.garment.name,
                        "| score:",
                        result.score
                    )
                }

                print("================================")
            }

        case .failure(let error):

            scoreError = """
            OCMCF recommendation error:
            \(error.localizedDescription)
            """

            print(
                "OCMCF recommendation failed:",
                error.localizedDescription
            )
        }

        isScoring = false
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {

        RestylePieceAddedView(
            pieceName: "Skirt",
            pieceImage: nil,
            selectedCategory: "bottoms"
        )
        .environmentObject(WardrobeStore())
    }
}
