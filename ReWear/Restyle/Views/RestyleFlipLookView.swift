
import SwiftUI

struct RestyleFlipLookView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.rewearReturnHome) private var returnHome

    let startingPiece: String
    let complementaryPiece: String

    @State private var selectedNudge: String? = "Shape"
    @State private var showLeaveConfirmation = false
    @State private var showWhatChanged = false
    @State private var shouldReturnHome = false

    private let nudges = [
        "Shape",
        "Details",
        "Mood"
    ]

    var body: some View {
        VStack(spacing: 0) {

            header
            progressBar

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    titleSection
                    illustration
                    nudgeSection

                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)

            continueButton
        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)

        // Next screen

        .navigationDestination(
            isPresented: $showWhatChanged
        ) {
            RestyleWhatChangedView(
                startingPiece: startingPiece,
                complementaryPiece: complementaryPiece
            )
        }

        // Custom Leave Challenge Sheet

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
        }    }

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

            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(
                        index < 2
                        ? Color(hex: 0x4478FF)
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
        Text("FLIP THE LOOK.")
            .font(RestyleTypography.editorial(42))
            .foregroundStyle(RestyleColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Illustration

    private var illustration: some View {
        Image("flip")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 290)
            .accessibilityHidden(true)
    }

    // MARK: - Creative Nudges

    private var nudgeSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            VStack(alignment: .leading, spacing: 4) {

                Text("CHOOSE A CREATIVE NUDGE")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(0.4)
                    .foregroundStyle(RestyleColors.textSecondary)

                Text(
                    "Optional inspiration — pick one or make your own."
                )
                .font(.system(size: 13))
                .foregroundStyle(RestyleColors.textSecondary)
            }

            VStack(spacing: 8) {

                ForEach(nudges, id: \.self) { nudge in
                    Button {
                        if selectedNudge == nudge {
                            selectedNudge = nil
                        } else {
                            selectedNudge = nudge
                        }
                    } label: {
                        nudgeRow(nudge)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Nudge Row

    private func nudgeRow(_ nudge: String) -> some View {

        let isSelected = selectedNudge == nudge

        return HStack(spacing: 12) {

            Text(nudge.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(0.3)
                .foregroundStyle(RestyleColors.textPrimary)
                .frame(width: 65, alignment: .leading)

            Text(descriptionForNudge(nudge))
                .font(.system(size: 12))
                .foregroundStyle(RestyleColors.textSecondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Spacer(minLength: 4)

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
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 52)
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color(hex: 0xE8E8E8),
                    lineWidth: 1
                )
        }
        .shadow(
            color: .black.opacity(isSelected ? 0.08 : 0),
            radius: 5,
            y: 2
        )
    }

    // MARK: - Nudge Description

    private func descriptionForNudge(_ nudge: String) -> String {

        switch nudge {

        case "Shape":
            return "Change the balance of your look"

        case "Details":
            return "Try wearing your \(startingPiece.lowercased()) differently"

        case "Mood":
            return "Shift from polished to relaxed"

        default:
            return ""
        }
    }

    // MARK: - Continue

    private var continueButton: some View {
        Button {
            showWhatChanged = true
        } label: {

            Text("I've tried this look")
                .font(.system(size: 19, weight: .semibold))
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
        RestyleFlipLookView(
            startingPiece: "Blazer",
            complementaryPiece: "Jeans"
        )
    }
}
