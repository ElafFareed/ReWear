
import SwiftUI

struct RestyleLeaveChallengeSheet: View {

    @Environment(\.dismiss) private var dismiss

    let onLeave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Drag Handle

            Capsule()
                .fill(Color(hex: 0xCAC9CC))
                .frame(width: 40, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)

            // MARK: - Coral Accent

            Capsule()
                .fill(RestyleColors.coral)
                .frame(width: 66, height: 6)
                .padding(.top, 24)

            Text("LEAVE THE CHALLENGE?")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(RestyleColors.textSecondary)
                .padding(.top, 10)

            // MARK: - Title

            Text("Leave your looks?")
                .font(RestyleTypography.editorial(30))
                .foregroundStyle(RestyleColors.textPrimary)
                .padding(.top, 18)

            // MARK: - Description

            Text(
                "Your current challenge may not be saved. You can stay and finish whenever you're ready."
            )
            .font(RestyleTypography.body)
            .foregroundStyle(RestyleColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 20)

            Spacer(minLength: 20)

            // MARK: - Buttons

            VStack(spacing: 12) {

                Button {
                    dismiss()
                } label: {
                    Text("Keep Styling")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RestyleColors.lime,
                            in: Capsule()
                        )
                }

                Button {
                    onLeave()
                } label: {
                    Text("Leave Challenge")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(RestyleColors.coral)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            Color(hex: 0xEFEFEA),
                            in: Capsule()
                        )
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 18)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(RestyleColors.background)
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            RestyleLeaveChallengeSheet {
                // Preview only
            }
            .presentationDetents([.height(390)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(28)
        }
}

