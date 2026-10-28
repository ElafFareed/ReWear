
import SwiftUI

struct RemovePieceSheet: View {

    let garmentName: String
    let onKeep: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Red Accent Line

            Capsule()
                .fill(
                    Color(
                        red: 1,
                        green: 0.27,
                        blue: 0.34
                    )
                )
                .frame(width: 70, height: 6)
                .padding(.top, 30)

            // MARK: - Small Heading

            Text("REMOVE THIS PIECE?")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(RestyleColors.textSecondary)
                .padding(.top, 14)

            // MARK: - Garment Name

            Text("Remove \(garmentName)?")
                .font(RestyleTypography.editorial(28))
                .foregroundStyle(RestyleColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 25)

            // MARK: - Explanation

            Text("This removes the garment from My Wardrobe.")
                .font(RestyleTypography.body)
                .foregroundStyle(RestyleColors.textSecondary)
                .padding(.top, 22)

            Spacer(minLength: 20)

            // MARK: - Keep Piece Button

            Button {
                onKeep()
            } label: {
                Text("Keep Piece")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        RestyleColors.primaryActionText
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RestyleColors.lime,
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)

            // MARK: - Remove Piece Button

            Button(role: .destructive) {
                onRemove()
            } label: {
                Text("Remove Piece")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(
                        Color(
                            red: 1,
                            green: 0.27,
                            blue: 0.34
                        )
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Color(
                            red: 0.94,
                            green: 0.94,
                            blue: 0.91
                        ),
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - Preview

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            RemovePieceSheet(
                garmentName: "Black jacket",
                onKeep: {},
                onRemove: {}
            )
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(30)
        }
}

