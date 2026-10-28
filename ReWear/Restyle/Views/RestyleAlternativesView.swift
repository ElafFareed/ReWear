
import SwiftUI
import UIKit

struct RestyleAlternativesView: View {

    @Environment(\.dismiss) private var dismiss

    // MARK: - Recommendation Data

    let alternatives: [String]
    let recommendations: [OCMCFRecommendation]

    // MARK: - State

    @State private var selectedItem: String?
    @State private var showComplementaryPiece = false

    // MARK: - Initializer

    init(
        alternatives: [String] = [],
        recommendations: [OCMCFRecommendation] = []
    ) {
        self.alternatives = alternatives
        self.recommendations = recommendations
    }

    // MARK: - Properties

    private var hasModelRecommendations: Bool {
        !recommendations.isEmpty
    }

    private var selectedRecommendation: OCMCFRecommendation? {
        recommendations.first {
            $0.garment.id == selectedItem
        }
    }

    private var canContinue: Bool {
        selectedItem != nil
    }

    private var selectedCategory: String {
        guard let selectedRecommendation else {
            return selectedItem ?? "Clothing"
        }

        switch selectedRecommendation.garment.category {
        case "tops":
            return "Top"
        case "bottoms":
            return "Bottom"
        case "outerwear":
            return "Outerwear"
        default:
            return "Clothing"
        }
    }

    // MARK: - Main View

    var body: some View {

        VStack(spacing: 0) {

            header

            progressBar

            ScrollView {

                VStack(alignment: .leading, spacing: 0) {

                    titleSection
                        .padding(.top, 40)

                    alternativesSection
                        .padding(.top, 28)

                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            continueButton

        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)

        // MARK: - Next Screen

        .navigationDestination(
            isPresented: $showComplementaryPiece
        ) {
            RestyleComplementaryPieceView(
                selectedItem: selectedCategory
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

        VStack(alignment: .leading, spacing: 12) {

            Text("WHAT ELSE\nDO YOU OWN?")
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
                "Here are other pieces OCMCF ranked for your outfit."
            )
            .font(RestyleTypography.body)
            .foregroundStyle(
                RestyleColors.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            Text(
                "Choose one that looks similar to something you already own."
            )
            .font(.system(size: 13))
            .foregroundStyle(
                RestyleColors.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
    }

    // MARK: - Alternatives

    private var alternativesSection: some View {

        VStack(spacing: 12) {

            if hasModelRecommendations {

                ForEach(
                    Array(recommendations.enumerated()),
                    id: \.element.id
                ) { index, recommendation in

                    Button {

                        selectedItem =
                            recommendation.garment.id

                    } label: {

                        recommendationRow(
                            recommendation,
                            rank: index + 2
                        )
                    }
                    .buttonStyle(.plain)
                }

            } else if !alternatives.isEmpty {

                // Backward compatibility with old screens.

                ForEach(alternatives, id: \.self) { item in

                    Button {

                        selectedItem = item

                    } label: {

                        legacyAlternativeRow(item)
                    }
                    .buttonStyle(.plain)
                }

            } else {

                ContentUnavailableView(
                    "No Alternatives Yet",
                    systemImage: "hanger",
                    description: Text(
                        "There are no additional recommendations available."
                    )
                )
            }
        }
    }

    // MARK: - OCMCF Recommendation Row

    private func recommendationRow(
        _ recommendation: OCMCFRecommendation,
        rank: Int
    ) -> some View {

        let isSelected =
            selectedItem == recommendation.garment.id

        return HStack(spacing: 14) {

            // Actual garment image

            if let image =
                RestyleOCMCFRecommendationService.shared.image(
                    for: recommendation.garment
                ) {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 86, height: 100)
                    .clipped()
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )

            } else {

                Image(systemName: "hanger")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        RestyleColors.textSecondary
                    )
                    .frame(width: 86, height: 100)
                    .background(
                        Color(hex: 0xEEEEEE),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }

            // Recommendation details

            VStack(alignment: .leading, spacing: 8) {

                Text("OCMCF PICK #\(rank)")
                    .font(
                        .system(
                            size: 10,
                            weight: .semibold
                        )
                    )
                    .tracking(0.4)
                    .foregroundStyle(
                        RestyleColors.textSecondary
                    )

                Text(recommendation.garment.name)
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        RestyleColors.textPrimary
                    )
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                Text(
                    "Compatibility score: \(recommendation.score, specifier: "%.3f")"
                )
                .font(.system(size: 11))
                .foregroundStyle(
                    RestyleColors.textSecondary
                )
            }

            Spacer(minLength: 4)

            Image(
                systemName: isSelected
                ? "checkmark.circle.fill"
                : "circle"
            )
            .font(.system(size: 23))
            .foregroundStyle(
                isSelected
                ? RestyleColors.lime
                : Color(hex: 0xD5D7D5)
            )

        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 18)
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
        .contentShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - Legacy Alternative Row

    private func legacyAlternativeRow(
        _ item: String
    ) -> some View {

        let isSelected = selectedItem == item

        return HStack(spacing: 14) {

            Image(systemName: "hanger")
                .font(.system(size: 30))
                .foregroundStyle(
                    RestyleColors.textSecondary
                )
                .frame(width: 72, height: 72)
                .background(
                    Color(hex: 0xEEEEEE),
                    in: RoundedRectangle(cornerRadius: 14)
                )

            Text(item)
                .font(
                    .system(
                        size: 17,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RestyleColors.textPrimary
                )

            Spacer()

            Image(
                systemName: isSelected
                ? "checkmark.circle.fill"
                : "circle"
            )
            .font(.system(size: 22))
            .foregroundStyle(
                isSelected
                ? RestyleColors.lime
                : Color(hex: 0xD5D7D5)
            )
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 18)
        )
        .contentShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - Continue Button

    private var continueButton: some View {

        Button {

            guard canContinue else {
                return
            }

            showComplementaryPiece = true

        } label: {

            Text("Continue")
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    canContinue
                    ? Color.black
                    : Color(hex: 0x858585)
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
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(
            RestyleColors.background
        )
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {

        RestyleAlternativesView(
            alternatives: [
                "Trousers",
                "Skirt",
                "Shorts"
            ]
        )
    }
}
