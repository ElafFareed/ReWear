
import SwiftUI

struct ChooseYourPathView: View {

    // MARK: - Navigation State

    @State private var showRepurpose = false

    // MARK: - Path Model

    private struct PathOption: Identifiable {
        let id: String
        let title: String
        let condition: String
        let detail: String
        let image: String
        let accent: Color
    }

    // MARK: - Paths

    private let paths: [PathOption] = [
        PathOption(
            id: "restyle",
            title: "Restyle It",
            condition: "GOOD CONDITION",
            detail: "Create fresh looks with clothes you already own.",
            image: "RestyleIt",
            accent: Color(hex: 0xFEE8ED)
        ),

        PathOption(
            id: "repair",
            title: "Repair & Rewear",
            condition: "REPAIR / REUSE",
            detail: "Fix or refresh damaged clothes to wear them again.",
            image: "Repair",
            accent: Color(hex: 0xE1EBFD)
        ),

        PathOption(
            id: "repurpose",
            title: "Repurpose It",
            condition: "CREATE SOMETHING NEW",
            detail: "Turn an old garment into something useful.",
            image: "Repurposeit",
            accent: Color(hex: 0xF2FDD3)
        )
    ]

    // MARK: - Body

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Header

                HStack {

                    Text("REWEAR / STUDIO")
                        .font(.system(size: 15, weight: .medium))
                        .tracking(0.6)
                        .foregroundStyle(RestyleColors.textPrimary)

                    Spacer()

                    NavigationLink {
                        MyWardrobeView()
                    } label: {
                        HStack(spacing: 6) {

                            Image(systemName: "hanger")

                            Text("My Wardrobe")

                            Image(systemName: "chevron.right")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(RestyleColors.textPrimary)
                        .padding(.horizontal, 10)
                        .frame(height: 43)
                        .background(
                            RestyleColors.surfaceRaised,
                            in: RoundedRectangle(
                                cornerRadius: RestyleRadius.control
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, RestyleSpacing.regular)

                // MARK: Main Heading

                Text("GIVE YOUR CLOTHES\nANOTHER LIFE.")
                    .font(RestyleTypography.editorial(38))
                    .foregroundStyle(RestyleColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, RestyleSpacing.section)
                    .accessibilityAddTraits(.isHeader)

                Text("What would you like to do with your clothes?")
                    .font(RestyleTypography.body)
                    .foregroundStyle(RestyleColors.textSecondary)
                    .padding(.top, RestyleSpacing.small)

                // MARK: Path Cards

                VStack(spacing: RestyleSpacing.small) {
                    ForEach(paths) { path in
                        pathCard(path)
                    }
                }
                .padding(.top, RestyleSpacing.section)

                // MARK: Sustainability Tip

                sustainabilityTip
                    .padding(.top, RestyleSpacing.section)
                    .padding(.bottom, RestyleSpacing.xLarge)

            }
            .padding(.horizontal, RestyleSpacing.screenPadding)
        }
        .scrollIndicators(.hidden)
        .background(
            RestyleColors.background.ignoresSafeArea()
        )

        // MARK: Repurpose Navigation

        .fullScreenCover(isPresented: $showRepurpose) {
            MyRepurposeFlowView()
        }
    }

    // MARK: - Path Navigation

    private func pathCard(_ path: PathOption) -> some View {

        Group {

            if path.id == "restyle" {

                // Restyle It

                NavigationLink {
                    ChooseYourPieceView()
                } label: {
                    cardContent(path)
                }
                .buttonStyle(.plain)

            } else if path.id == "repurpose" {

                // Repurpose It

                Button {
                    showRepurpose = true
                } label: {
                    cardContent(path)
                }
                .buttonStyle(.plain)

            } else {

                // Repair & Rewear
                // Preserve current behavior

                cardContent(path)
            }
        }
    }

    // MARK: - Card Content

    private func cardContent(_ path: PathOption) -> some View {

        HStack(spacing: RestyleSpacing.medium) {

            // Card Illustration

            ZStack {

                RoundedRectangle(
                    cornerRadius: RestyleRadius.control
                )
                .fill(path.accent)

                Image(path.image)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            }
            .frame(width: 88, height: 108)
            .accessibilityHidden(true)

            // Card Text

            VStack(alignment: .leading, spacing: 6) {

                Text(path.title)
                    .font(RestyleTypography.headline)
                    .foregroundStyle(RestyleColors.textPrimary)

                Text(path.condition)
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(RestyleColors.textSecondary)

                Text(path.detail)
                    .font(.system(size: 12))
                    .foregroundStyle(RestyleColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }

            Spacer(minLength: 0)

            // Arrow

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(RestyleColors.primaryActionText)
                .frame(width: 27, height: 27)
                .background(
                    RestyleColors.lime,
                    in: Circle()
                )
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 128)
        .background(
            cardBackground(for: path.id),
            in: RoundedRectangle(
                cornerRadius: RestyleRadius.card
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: RestyleRadius.card
            )
            .strokeBorder(
                RestyleColors.border.opacity(0.65)
            )
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    // MARK: - Card Background

    private func cardBackground(for id: String) -> Color {

        switch id {

        case "restyle":
            return Color(hex: 0xFEE8ED)

        case "repair":
            return Color(hex: 0xE1EBFD)

        case "repurpose":
            return Color(hex: 0xF2FDD3)

        default:
            return RestyleColors.surface
        }
    }

    // MARK: - Sustainability Tip

    private var sustainabilityTip: some View {

        HStack(spacing: RestyleSpacing.medium) {

            VStack(alignment: .leading, spacing: 6) {

                Text("A LITTLE SUSTAINABILITY TIP")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.4)
                    .foregroundStyle(RestyleColors.textSecondary)

                Text(
                    "Keeping clothes in use longer can help reduce textile waste."
                )
                .font(.system(size: 12))
                .foregroundStyle(RestyleColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(
            RestyleColors.surfaceRaised,
            in: RoundedRectangle(
                cornerRadius: RestyleRadius.card
            )
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChooseYourPathView()
    }
    .environmentObject(WardrobeStore())
}

