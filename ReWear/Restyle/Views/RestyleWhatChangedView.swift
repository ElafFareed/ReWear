
import SwiftUI

struct RestyleWhatChangedView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.rewearReturnHome) private var returnHome
    let startingPiece: String
    let complementaryPiece: String

    @State private var selectedReflection: String? =
        "Change the balance of your look"

    @State private var showChallengeComplete = false
    @State private var showLeaveConfirmation = false

    private let reflectionOptions = [
        "Change the balance of your look",
        "A little — I want to try more",
        "Not yet"
    ]

    // MARK: - Main View

    var body: some View {
        VStack(spacing: 0) {

            header

            progressBar

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    titleSection
                        .padding(.top, 32)

                    illustration
                        .padding(.top, 18)

                    reflectionSection
                        .padding(.top, 18)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            finishButton
        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)

        // MARK: - Challenge Complete Navigation

        .navigationDestination(
            isPresented: $showChallengeComplete
        ) {
            RestyleChallengeCompleteView()
        }

        // MARK: - Leave Confirmation

        .confirmationDialog(
            "Leave Restyle?",
            isPresented: $showLeaveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Keep Styling", role: .cancel) {}

            Button("Leave Challenge", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Your current challenge may not be saved.")
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

    // MARK: - Header Icon

    private func headerIcon(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(RestyleColors.textPrimary)
            .frame(width: 40, height: 40)
            .background(
                RestyleColors.surfaceRaised,
                in: RoundedRectangle(cornerRadius: 12)
            )
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 8) {

            ForEach(0..<3, id: \.self) { _ in
                Capsule()
                    .fill(Color(hex: 0x4F74FF))
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("WHAT CHANGED?")
                .font(RestyleTypography.editorial(34))
                .foregroundStyle(RestyleColors.textPrimary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(
                "You tried two ways to style the same pieces.\nWhat did you discover?"
            )
            .font(.system(size: 13))
            .foregroundStyle(RestyleColors.textSecondary)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
    }

    // MARK: - Illustration

    private var illustration: some View {
        Image("whatchanged")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 235)
            .accessibilityHidden(true)
    }

    // MARK: - Reflection Section

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text(
                "Did you discover a new way to style your piece?"
            )
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(RestyleColors.textPrimary)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            VStack(spacing: 10) {

                ForEach(reflectionOptions, id: \.self) { option in

                    Button {
                        selectedReflection = option
                    } label: {
                        reflectionRow(option)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Reflection Row

    private func reflectionRow(
        _ option: String
    ) -> some View {

        let isSelected = selectedReflection == option

        return HStack(spacing: 12) {

            ZStack {

                Circle()
                    .strokeBorder(
                        isSelected
                        ? RestyleColors.textPrimary
                        : RestyleColors.border,
                        lineWidth: 1.5
                    )
                    .frame(width: 22, height: 22)

                if isSelected {

                    Circle()
                        .fill(RestyleColors.lime)
                        .frame(width: 18, height: 18)

                    Image(systemName: "checkmark")
                        .font(
                            .system(
                                size: 10,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.black)
                }
            }

            Text(option)
                .font(.system(size: 14))
                .foregroundStyle(RestyleColors.textPrimary)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .frame(maxWidth: .infinity)
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    RestyleColors.border.opacity(0.8)
                )
        }
    }

    // MARK: - Finish Challenge Button

    private var finishButton: some View {
        Button {
            showChallengeComplete = true
        } label: {

            Text("Finish Challenge")
                .font(
                    .system(
                        size: 19,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RestyleColors.primaryActionText
                )
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RestyleColors.lime,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(RestyleColors.background)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RestyleWhatChangedView(
            startingPiece: "Blazer",
            complementaryPiece: "Jeans"
        )
    }
}
