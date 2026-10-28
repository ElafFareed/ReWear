
import SwiftUI
import UIKit

struct RestylePieceAddedView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var wardrobeStore: WardrobeStore

    // MARK: - Starting Piece

    let pieceName: String
    let pieceImage: UIImage?
    var startingGarment: Garment? = nil

    // MARK: - State

    @State private var isScoring = false
    @State private var recommendedPieces: [OCMCFRecommendation] = []
    @State private var scoreError: String?
    @State private var showOwnership = false

    // MARK: - Best Recommendation

    private var bestRecommendation: OCMCFRecommendation? {
        recommendedPieces.first
    }

    // MARK: - Main View

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Header

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

            // MARK: - Progress Bar

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

            // MARK: - Main Content

            ScrollView {

                VStack(alignment: .leading, spacing: 18) {

                    Text("Piece added!")
                        .font(RestyleTypography.editorial(42))
                        .foregroundStyle(RestyleColors.textPrimary)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )

                    Image("finished")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)

                    // MARK: - Recommendation State

                    if isScoring {

                        loadingSection

                    } else if let recommendation = bestRecommendation {

                        recommendationSection(recommendation)

                    } else {

                        Text(
                            scoreError ??
                            "You're one step closer to new looks"
                        )
                        .font(RestyleTypography.body)
                        .foregroundStyle(
                            RestyleColors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 24)
            }

            // MARK: - Continue Button

            Button {

                guard bestRecommendation != nil,
                      !isScoring else {
                    return
                }

                showOwnership = true

            } label: {

                Text(
                    isScoring
                    ? "Finding a match..."
                    : "Continue"
                )
                .font(
                    .system(
                        size: 19,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    bestRecommendation != nil
                    ? Color.black
                    : RestyleColors.textSecondary
                )
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    bestRecommendation != nil
                    ? RestyleColors.lime
                    : Color(hex: 0xEFEFEA),
                    in: Capsule()
                )
            }
            .buttonStyle(.plain)
            .disabled(
                bestRecommendation == nil || isScoring
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 10)

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
                    recommendations: recommendedPieces
                )
            }
        }

        // MARK: - Run OCMCF Recommendation

        .task(id: startingGarment?.id) {
            await findRecommendation()
        }
    }

    // MARK: - Loading Section

    private var loadingSection: some View {

        VStack(spacing: 14) {

            ProgressView()
                .scaleEffect(1.2)

            Text("Finding your complementary piece...")
                .font(RestyleTypography.body)
                .foregroundStyle(
                    RestyleColors.textSecondary
                )
                .multilineTextAlignment(.center)

            Text("OCMCF is comparing your garment with pieces from our offline fashion catalog.")
                .font(.system(size: 13))
                .foregroundStyle(
                    RestyleColors.textSecondary
                )
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Recommended Garment Section

    private func recommendationSection(
        _ recommendation: OCMCFRecommendation
    ) -> some View {

        VStack(spacing: 14) {

            Text("RECOMMENDED FOR YOUR OUTFIT")
                .font(
                    .system(
                        size: 12,
                        weight: .semibold
                    )
                )
                .tracking(0.5)
                .foregroundStyle(
                    RestyleColors.textSecondary
                )

            // Actual garment image from offline catalog

            if let image =
                RestyleOCMCFRecommendationService.shared.image(
                    for: recommendation.garment
                ) {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                    .accessibilityLabel(
                        recommendation.garment.name
                    )

            } else {

                Image(systemName: "hanger")
                    .font(.system(size: 45))
                    .foregroundStyle(
                        RestyleColors.textSecondary
                    )
                    .frame(height: 150)
            }

            // Model selected garment name

            Text(recommendation.garment.name)
                .font(
                    .system(
                        size: 20,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RestyleColors.textPrimary
                )
                .multilineTextAlignment(.center)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            // Recommendation explanation

            Text(
                "OCMCF selected this piece to complement your starting garment."
            )
            .font(.system(size: 13))
            .foregroundStyle(
                RestyleColors.textSecondary
            )
            .multilineTextAlignment(.center)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            Text(
                "Next, we'll check whether you already own something similar."
            )
            .font(.system(size: 13))
            .foregroundStyle(
                RestyleColors.textSecondary
            )
            .multilineTextAlignment(.center)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    // MARK: - Find OCMCF Recommendation

    @MainActor
    private func findRecommendation() async {

        recommendedPieces = []
        scoreError = nil
        isScoring = true

        // STEP 1: Get actual selected garment image

        let selectedImage: UIImage? = pieceImage ?? {
            guard let startingGarment else {
                return nil
            }

            return wardrobeStore.image(
                for: startingGarment
            )
        }()

        guard let selectedImage else {

            scoreError = """
            Please select a garment with a photo to receive a recommendation.
            """

            isScoring = false
            return
        }

        // STEP 2: Determine garment category

        let categoryText = [
            startingGarment.map {
                String(describing: $0.category)
            } ?? "",
            startingGarment?.subcategory ?? "",
            pieceName
        ]
        .joined(separator: " ")
        .lowercased()

        let bottomKeywords = [
            "bottom",
            "skirt",
            "jean",
            "trouser",
            "pant",
            "short",
            "legging"
        ]

        let topKeywords = [
            "top",
            "shirt",
            "blouse",
            "sweater",
            "tee",
            "tshirt",
            "t-shirt",
            "tank",
            "hoodie"
        ]

        let workflow: String

        if bottomKeywords.contains(
            where: categoryText.contains
        ) {

            workflow = "bottoms"

        } else if topKeywords.contains(
            where: categoryText.contains
        ) {

            workflow = "tops"

        } else {

            scoreError = """
            For this demo, please choose a top or bottom garment.
            """

            isScoring = false
            return
        }

        // STEP 3: Load offline garment catalog

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

        // STEP 4: Run the real Core ML models
        // in the background so the UI stays responsive.

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

                    if workflow == "bottoms" {

                        // Bottom -> Top

                        ranked = try engine.recommendTops(
                            forImage: selectedImage,
                            limit: 5
                        )

                    } else {

                        // Top -> Outerwear

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

        // STEP 5: Display highest-ranked garment

        switch results {

        case .success(let ranked):

            recommendedPieces = ranked

            if ranked.isEmpty {
                scoreError = "No complementary pieces were found."
            }

            if let best = ranked.first {

                print("")
                print("===== OCMCF RECOMMENDATION =====")
                print("Starting piece:", pieceName)
                print("Workflow:", workflow)
                print("Recommended:", best.garment.name)
                print("Model score:", best.score)

                print("Other ranked alternatives:")

                for result in ranked.dropFirst() {
                    print(
                        result.garment.name,
                        "|",
                        result.score
                    )
                }

                print("===============================")
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

    // MARK: - Header Icon

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
            .frame(
                width: 48,
                height: 48
            )
            .background(
                Color(hex: 0xF2F1F3),
                in: RoundedRectangle(
                    cornerRadius: 16
                )
            )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RestylePieceAddedView(
            pieceName: "Skirt",
            pieceImage: nil
        )
        .environmentObject(
            WardrobeStore()
        )
    }
}
