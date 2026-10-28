import SwiftUI

struct RestyleSetMoodView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.rewearReturnHome) private var returnHome

    let startingPiece: String
    let complementaryPiece: String

    @State private var showFlipLook = false
    @State private var showLeaveConfirmation = false
    @State private var shouldReturnHome = false

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

        // MARK: Next Screen

        .navigationDestination(
            isPresented: $showFlipLook
        ) {
            RestyleFlipLookView(
                startingPiece: startingPiece,
                complementaryPiece: complementaryPiece
            )
        }

        // MARK: Leave Challenge

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

    // MARK: Header

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

    // MARK: Progress

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

    // MARK: Title

    private var titleSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("SET THE MOOD.")
                .font(RestyleTypography.editorial(42))
                .foregroundStyle(RestyleColors.textPrimary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(
                "Create a fresh look with the pieces you own."
            )
            .font(RestyleTypography.body)
            .foregroundStyle(RestyleColors.textSecondary)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
    }

    // MARK: Illustration

    private var illustration: some View {

        Image("setmood")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 300)
    }

    // MARK: Action

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

    // MARK: Continue

    private var continueButton: some View {

        Button {
            showFlipLook = true
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

#Preview {
    NavigationStack {
        RestyleSetMoodView(
            startingPiece: "Blazer",
            complementaryPiece: "Jeans"
        )
    }
}
