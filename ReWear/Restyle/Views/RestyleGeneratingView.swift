import SwiftUI

struct RestyleGeneratingView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.rewearReturnHome) private var returnHome
    // Passed from the previous Restyle screens.
    let startingPiece: String
    let complementaryPiece: String

    // Actual processing state will be connected later.
    var isProcessing: Bool = true

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(RestyleColors.textPrimary)
                        .frame(width: 48, height: 48)
                        .background(
                            Color(hex: 0xF2F1F3),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            // MARK: - Progress Indicator

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    Capsule()
                        .fill(RestyleColors.coral)
                        .frame(height: 5)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // MARK: - Content

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text("YOUR CREATIVITY, IN MOTION")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.6)
                        .foregroundStyle(
                            RestyleColors.textSecondary
                        )

                    Image("setlook")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 355)

                    Text("Creating your\nRestyle...")
                        .font(RestyleTypography.editorial(36))
                        .foregroundStyle(
                            RestyleColors.textPrimary
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Text(
                        "Using only garments you confirmed you own."
                    )
                    .font(RestyleTypography.body)
                    .foregroundStyle(
                        RestyleColors.textSecondary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                    // Indeterminate loading indicator.
                    // This does not represent a fabricated
                    // percentage of model completion.
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(.linear)
                            .tint(Color(hex: 0x4478FF))
                            .padding(.top, 24)

                        Text("Preparing your Restyle...")
                            .font(.system(size: 12))
                            .foregroundStyle(
                                RestyleColors.textSecondary
                            )
                    } else {
                        Text("Ready for your next look")
                            .font(RestyleTypography.body)
                            .foregroundStyle(
                                RestyleColors.textPrimary
                            )
                            .padding(.top, 24)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        RestyleGeneratingView(
            startingPiece: "Blazer",
            complementaryPiece: "Jeans"
        )
    }
}

