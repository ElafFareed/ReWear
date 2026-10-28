
import SwiftUI

struct RestyleSetMoodView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.rewearReturnHome) private var returnHome
    // Garments selected earlier in the Restyle flow
    let startingPiece: String
    let complementaryPiece: String

    @State private var showNextLook = false
    @State private var showLeaveConfirmation = false

    var body: some View {
        VStack(spacing: 0) {

            header

            progressBar

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    titleSection

                    illustration

                    actionCard
                }
                .padding(.horizontal, 24)
                .padding(.top, 38)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            continueButton
        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)

        // MARK: - Leave Confirmation

        .confirmationDialog(
            "Leave Restyle?",
            isPresented: $showLeaveConfirmation
        ) {
            Button("Keep Styling", role: .cancel) {}

            Button("Go Back", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Do you want to leave this styling challenge?")
        }

        // MARK: - Temporary Completion Alert

        .alert(
            "Look Complete!",
            isPresented: $showNextLook
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "Great! Let's explore another way to style your outfit."
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
                showLeaveConfirmation = true
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

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                Capsule()
                    .fill(Color(hex: 0x4478FF))
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("SET THE MOOD.")
                .font(RestyleTypography.editorial(42))
                .foregroundStyle(RestyleColors.textPrimary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text("Create a fresh look with the pieces you own.")
                .font(RestyleTypography.body)
                .foregroundStyle(RestyleColors.textSecondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
    }

    // MARK: - Illustration

    private var illustration: some View {
        Image("setmood")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 300)
    }

    // MARK: - Your Action Card

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("YOUR ACTION")
                .font(.system(size: 12, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(RestyleColors.textPrimary)

            Text(
                "Style your \(startingPiece.lowercased()) with your \(complementaryPiece.lowercased()) to create a fresh look."
            )
            .font(RestyleTypography.body)
            .foregroundStyle(RestyleColors.textPrimary)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(22)
        .background(
            Color(hex: 0xFEE8ED),
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            showNextLook = true
        } label: {

            Text("I've tried this look")
                .font(
                    .system(
                        size: 19,
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
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(RestyleColors.background)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RestyleSetMoodView(
            startingPiece: "Blazer",
            complementaryPiece: "Jeans"
        )
    }
}

