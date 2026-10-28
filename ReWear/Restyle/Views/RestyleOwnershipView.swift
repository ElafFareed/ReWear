import SwiftUI
import UIKit

struct RestyleOwnershipView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.rewearReturnHome) private var returnHome

    let suggestedItem: String
    let startingPiece: String
    let recommendations: [OCMCFRecommendation]

    @State private var showAlternatives = false
    @State private var showGenerating = false
    @State private var showLeaveConfirmation = false
    @State private var shouldReturnHome = false

    init(
        suggestedItem: String,
        startingPiece: String = "Your piece",
        recommendations: [OCMCFRecommendation] = []
    ) {
        self.suggestedItem = suggestedItem
        self.startingPiece = startingPiece
        self.recommendations = recommendations
    }

    private var bestRecommendation: OCMCFRecommendation? {
        recommendations.first
    }

    private var otherRecommendations: [OCMCFRecommendation] {
        Array(recommendations.dropFirst())
    }

    private var suggestedCategory: String {
        guard let category = bestRecommendation?.garment.category else {
            return "clothing piece"
        }

        switch category {
        case "tops":
            return "top"
        case "bottoms":
            return "bottom"
        case "outerwear":
            return "jacket or outerwear piece"
        default:
            return "clothing piece"
        }
    }

    var body: some View {

        VStack(spacing: 0) {

            // MARK: Header

            HStack {

                Button {
                    dismiss()
                } label: {
                    headerButton("chevron.left")
                }

                Spacer()

                Button {
                    showLeaveConfirmation = true
                } label: {
                    headerButton("xmark")
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            // MARK: Progress

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

            // MARK: Content

            ScrollView {

                VStack(alignment: .leading, spacing: 18) {

                    Text("DO YOU OWN\nSOMETHING SIMILAR?")
                        .font(RestyleTypography.editorial(38))
                        .foregroundStyle(RestyleColors.textPrimary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Text(
                        "OCMCF recommended this \(suggestedCategory) for your outfit."
                    )
                    .font(RestyleTypography.body)
                    .foregroundStyle(RestyleColors.textSecondary)

                    // MARK: Recommendation Card

                    VStack(spacing: 14) {

                        if let bestRecommendation,
                           let image =
                            RestyleOCMCFRecommendationService.shared.image(
                                for: bestRecommendation.garment
                            ) {

                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 230)
                                .frame(maxWidth: .infinity)
                                .accessibilityLabel(
                                    bestRecommendation.garment.name
                                )

                        } else {

                            Image("Ownership")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 230)
                                .frame(maxWidth: .infinity)
                        }

                        Text(suggestedItem)
                            .font(
                                .system(
                                    size: 19,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(RestyleColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(
                            "You don't need this exact item. A similar piece from your wardrobe works too."
                        )
                        .font(.system(size: 13))
                        .foregroundStyle(RestyleColors.textSecondary)
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

                    Text(
                        "We'll only build your styling challenge around garments you confirm you own."
                    )
                    .font(RestyleTypography.body)
                    .foregroundStyle(RestyleColors.textSecondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            // MARK: Buttons

            VStack(spacing: 12) {

                Button {
                    showGenerating = true
                } label: {

                    Text("Yes, I have something similar")
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RestyleColors.lime,
                            in: Capsule()
                        )
                }

                Button {
                    showAlternatives = true
                } label: {

                    Text("No, show alternatives")
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(RestyleColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            Color.white,
                            in: Capsule()
                        )
                        .overlay {
                            Capsule()
                                .stroke(
                                    Color(hex: 0xE8E8E8),
                                    lineWidth: 1
                                )
                        }
                }
                .disabled(otherRecommendations.isEmpty)
                .opacity(
                    otherRecommendations.isEmpty ? 0.5 : 1
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)

        // MARK: Alternatives

        .navigationDestination(
            isPresented: $showAlternatives
        ) {
            RestyleAlternativesView(
                startingPiece: startingPiece,
                recommendations: otherRecommendations
            )
        }

        // MARK: Creating Your Restyle

        .navigationDestination(
            isPresented: $showGenerating
        ) {
            RestyleGeneratingView(
                startingPiece: startingPiece,
                complementaryPiece: suggestedItem
            )
        }

        // MARK: Leave Confirmation

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

    // MARK: Header Icon

    private func headerButton(
        _ symbol: String
    ) -> some View {

        Image(systemName: symbol)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(RestyleColors.textPrimary)
            .frame(width: 48, height: 48)
            .background(
                Color(hex: 0xF2F1F3),
                in: RoundedRectangle(cornerRadius: 16)
            )
    }
}

#Preview {
    NavigationStack {
        RestyleOwnershipView(
            suggestedItem: "Black V-Neck Sweater"
        )
    }
}
