import SwiftUI

struct EmptyWardrobeView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var wardrobeStore: WardrobeStore

    // MARK: - Body

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Back Button

            HStack {

                Button {
                    dismiss()
                } label: {

                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(RestyleColors.textPrimary)
                        .frame(width: 34, height: 34)
                        .background(
                            RestyleColors.surfaceRaised,
                            in: RoundedRectangle(cornerRadius: 11)
                        )
                }

                Spacer()
            }
            .padding(.top, 8)

            // MARK: - Heading

            Text("MY WARDROBE.")
                .font(RestyleTypography.editorial(36))
                .foregroundStyle(RestyleColors.textPrimary)
                .padding(.top, 26)

            Text("Your saved clothing will show up here.")
                .font(.system(size: 14))
                .foregroundStyle(RestyleColors.textSecondary)
                .padding(.top, 8)

            Spacer(minLength: 12)

            // MARK: - Wardrobe Illustration

            Image("wardrobe")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 438)

            // MARK: - Empty Wardrobe Message

            VStack(alignment: .leading, spacing: 5) {

                Text("EVERY PIECE STARTS HERE.")
                    .font(RestyleTypography.editorial(26))
                    .foregroundStyle(RestyleColors.textPrimary)

                Text(
                    "Save the clothes you own and use them for future creative challenges."
                )
                .font(.system(size: 15))
                .foregroundStyle(RestyleColors.textSecondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }
            .padding(.top, 20)

            Spacer(minLength: 20)

            // MARK: - Add First Piece Button

            NavigationLink {
                WardrobeCategoriesView()
            } label: {

                Text("Add Your First Piece")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RestyleColors.primaryActionText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RestyleColors.lime,
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)

            Spacer()
                .frame(height: 20)
        }
        .padding(.horizontal, RestyleSpacing.screenPadding)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {

        EmptyWardrobeView()
    }
    .environmentObject(WardrobeStore())
}
