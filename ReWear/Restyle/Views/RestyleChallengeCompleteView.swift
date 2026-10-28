import SwiftUI

struct RestyleChallengeCompleteView: View {

    @Environment(\.rewearReturnHome) private var returnHome

    var body: some View {

        VStack(spacing: 0) {

            Spacer()
                .frame(height: 40)

            VStack(alignment: .leading, spacing: 10) {

                Text("THAT LOOK WAS ALL YOU")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.6)
                    .foregroundStyle(RestyleColors.textSecondary)

                Text("CHALLENGE\nCOMPLETE")
                    .font(RestyleTypography.editorial(36))
                    .foregroundStyle(RestyleColors.textPrimary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Image("finished")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 420)
                .padding(.top, 10)
                .accessibilityHidden(true)

            Spacer()

            VStack(spacing: 14) {

                NavigationLink {
                    ChooseYourPieceView()
                } label: {

                    Text("Try Another Challenge")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(RestyleColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Color.white,
                            in: Capsule()
                        )
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    RestyleColors.border.opacity(0.8)
                                )
                        }
                }
                .buttonStyle(.plain)

                Button {
                    returnHome()
                } label: {

                    Text("Home")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            RestyleColors.primaryActionText
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RestyleColors.lime,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        RestyleChallengeCompleteView()
            .environmentObject(WardrobeStore())
    }
}
