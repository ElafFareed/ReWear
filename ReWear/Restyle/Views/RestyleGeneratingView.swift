import SwiftUI

struct RestyleGeneratingView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.rewearReturnHome) private var returnHome

    // MARK: - Garment Data

    let startingPiece: String
    let complementaryPiece: String

    // MARK: - State

    @State private var showSetMood = false
    @State private var showLeaveConfirmation = false
    @State private var shouldReturnHome = false

    // Temporary loading state.
    // Later, this can be connected to actual processing.
    @State private var isProcessing = true

    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Header

            header

            // MARK: - Progress Bar

            progressBar

            // MARK: - Content

            ScrollView {

                VStack(alignment: .leading, spacing: 16) {

                    Text("YOUR CREATIVITY, IN MOTION")
                        .font(
                            .system(
                                size: 11,
                                weight: .semibold
                            )
                        )
                        .tracking(0.6)
                        .foregroundStyle(
                            RestyleColors.textSecondary
                        )

                    // Illustration from Assets

                    Image("setlook")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 355)
                        .accessibilityHidden(true)

                    // Title

                    Text("Creating your\nRestyle...")
                        .font(
                            RestyleTypography.editorial(36)
                        )
                        .foregroundStyle(
                            RestyleColors.textPrimary
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    // Description

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

                    // MARK: - Loading Indicator

                    if isProcessing {

                        ProgressView()
                            .progressViewStyle(.linear)
                            .tint(
                                Color(hex: 0x4478FF)
                            )
                            .padding(.top, 24)

                        Text("Preparing your Restyle...")
                            .font(.system(size: 12))
                            .foregroundStyle(
                                RestyleColors.textSecondary
                            )

                    } else {

                        Text("Your Restyle is ready!")
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

        // MARK: - Background

        .background(
            RestyleColors.background.ignoresSafeArea()
        )

        .navigationBarBackButtonHidden(true)

        // MARK: - Navigate to Set the Mood

        .navigationDestination(
            isPresented: $showSetMood
        ) {

            RestyleSetMoodView(
                startingPiece: startingPiece,
                complementaryPiece: complementaryPiece
            )
        }

        // MARK: - Temporary Loading Process

        .task {

            isProcessing = true

            // Temporary delay for prototype UI.
            // Replace this when real preparation logic is ready.

            do {
                try await Task.sleep(
                    for: .seconds(1.5)
                )
            } catch {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            isProcessing = false

            // Move to Set the Mood

            showSetMood = true
        }

        // MARK: - Leave Challenge Sheet

        .sheet(
            isPresented: $showLeaveConfirmation,
            onDismiss: {

                if shouldReturnHome {

                    shouldReturnHome = false

                    // Reset NavigationStack.
                    // Returns to ChooseYourPathView.

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

            // Back Button

            Button {

                dismiss()

            } label: {

                headerIcon("chevron.left")
            }

            Spacer()

            // X Button

            Button {

                showLeaveConfirmation = true

            } label: {

                headerIcon("xmark")
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    // MARK: - Header Icon

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

    // MARK: - Progress Bar

    private var progressBar: some View {

        HStack(spacing: 8) {

            ForEach(0..<3, id: \.self) { _ in

                Capsule()
                    .fill(
                        RestyleColors.coral
                    )
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {

        RestyleGeneratingView(
            startingPiece: "Blazer",
            complementaryPiece: "Jeans"
        )
    }
}
