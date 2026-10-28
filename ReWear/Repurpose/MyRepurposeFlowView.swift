
import SwiftUI

struct MyRepurposeFlowView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var wardrobeStore: WardrobeStore

    @State private var garment = RepurposeGarment()
    @State private var selectedGuide: MyRepurposeGuide?
    @State private var screen: Screen = .piece
    @State private var showLeave = false

    private enum Screen {
        case piece
        case damage
        case ideas
        case guide
        case complete
    }

    // MARK: - Damage Options

    private let damageOptions: [(id: String, title: String, detail: String)] = [
        (
            "severe-bleach-damage",
            "Severe Bleach Damage",
            "Extensive discoloration or weakened areas."
        ),
        (
            "permanent-stains",
            "Permanent Stains",
            "Large marks unsuitable for regular wear."
        ),
        (
            "large-tears-holes",
            "Large Tears & Holes",
            "Damage that prevents wearing as usual."
        ),
        (
            "worn-out-fabric",
            "Worn-Out Fabric",
            "Fabric that has become thin or weak."
        )
    ]

    // Recommendations are already personalized by:
    // category, material, condition and damage type.

    private var recommendations: [MyRepurposeGuide] {
        MyRepurposeLibrary.recommendations(for: garment)
    }

    // MARK: - Main Flow

    var body: some View {

        Group {

            switch screen {

            case .piece:
                MyRepurposePieceDetailsView(
                    garment: $garment,
                    onBack: {
                        dismiss()
                    },
                    onContinue: {
                        screen = .damage
                    }
                )

            case .damage:
                damageScreen

            case .ideas:
                ideasScreen

            case .guide:
                if let selectedGuide {
                    guideScreen(selectedGuide)
                }

            case .complete:
                completionScreen
            }
        }

        // MARK: Custom Leave Guide Sheet

        .sheet(isPresented: $showLeave) {

            leaveGuideSheet
                .presentationDetents([.height(480)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(36)
                .presentationBackground(.white)
        }
    }

    // MARK: - Damage Selection Screen

    private var damageScreen: some View {

        VStack(alignment: .leading, spacing: 0) {

            backButton {
                screen = .piece
            }

            ScrollView {

                VStack(alignment: .leading, spacing: 14) {

                    Text("WHAT'S THE\nDAMAGE?")
                        .font(RestyleTypography.editorial(42))
                        .foregroundStyle(RestyleColors.textPrimary)
                        .padding(.top, 35)

                    Text("Select the type of damage on your piece.")
                        .font(.system(size: 14))
                        .foregroundStyle(RestyleColors.textSecondary)

                    ForEach(damageOptions.indices, id: \.self) { index in

                        let damage = damageOptions[index]

                        Button {

                            garment.damageType = damage.id
                            garment.condition = "damaged"

                            screen = .ideas

                        } label: {

                            HStack(spacing: 12) {

                                RoundedRectangle(cornerRadius: 3)
                                    .fill(RestyleColors.lime)
                                    .frame(width: 5)

                                VStack(
                                    alignment: .leading,
                                    spacing: 8
                                ) {

                                    Text(damage.title)
                                        .font(
                                            .system(
                                                size: 15,
                                                weight: .semibold
                                            )
                                        )
                                        .foregroundStyle(
                                            RestyleColors.textPrimary
                                        )

                                    Text(damage.detail)
                                        .font(.system(size: 12))
                                        .foregroundStyle(
                                            RestyleColors.textSecondary
                                        )
                                }
                                .padding(.vertical, 14)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(
                                        RestyleColors.textPrimary
                                    )
                            }
                            .padding(.horizontal, 14)
                            .frame(minHeight: 90)
                            .background(
                                Color.white,
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // MARK: RISE Statistics

                    if let outcomes = GarmentOutcomes.shared,
                       let stat = outcomes.overall(
                           condition: "damaged"
                       ) {

                        outcomeCard(
                            stat: stat,
                            source: outcomes.source
                        )
                        .padding(.top, 12)
                    }
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 20)
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
    }

    // MARK: - Personalized Recommendations Screen

    private var ideasScreen: some View {

        VStack(alignment: .leading, spacing: 0) {

            backButton {
                screen = .damage
            }

            ScrollView {

                VStack(alignment: .leading, spacing: 14) {

                    Text("YOUR REPURPOSE\nIDEAS.")
                        .font(RestyleTypography.editorial(36))
                        .foregroundStyle(RestyleColors.textPrimary)
                        .padding(.top, 30)

                    Text(
                        "Ideas matched to your garment type, material and damage."
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(RestyleColors.textSecondary)

                    Text(
                        "\(garment.subcategory.isEmpty ? garment.category : garment.subcategory) · \(garment.material)"
                    )
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RestyleColors.textPrimary)
                    .padding(.vertical, 8)

                    // MARK: No Matching Projects

                    if recommendations.isEmpty {

                        VStack(
                            alignment: .leading,
                            spacing: 12
                        ) {

                            Text("NO SUITABLE PROJECTS YET.")
                                .font(
                                    RestyleTypography.editorial(22)
                                )

                            Text(
                                "There isn't a matching guide for this garment and damage combination. Try another piece or check that its type and material are correct."
                            )
                            .font(.system(size: 13))
                            .foregroundStyle(
                                RestyleColors.textSecondary
                            )

                            Text(
                                "Available offline guides: \(MyRepurposeLibrary.guides.count)"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                RestyleColors.textSecondary
                            )
                        }
                        .padding(20)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .background(
                            Color.white,
                            in: RoundedRectangle(cornerRadius: 16)
                        )

                    } else {

                        // MARK: Recommended Projects

                        ForEach(recommendations) { guide in

                            Button {

                                selectedGuide = guide
                                screen = .guide

                            } label: {

                                HStack(spacing: 14) {

                                    Image(systemName: guide.symbol)
                                        .font(.system(size: 24))
                                        .foregroundStyle(
                                            RestyleColors.textPrimary
                                        )
                                        .frame(width: 42, height: 42)
                                        .background(
                                            RestyleColors.lime.opacity(0.4),
                                            in: RoundedRectangle(
                                                cornerRadius: 12
                                            )
                                        )

                                    VStack(
                                        alignment: .leading,
                                        spacing: 6
                                    ) {

                                        Text(guide.title)
                                            .font(
                                                .system(
                                                    size: 15,
                                                    weight: .semibold
                                                )
                                            )
                                            .foregroundStyle(
                                                RestyleColors.textPrimary
                                            )

                                        Text(guide.summary)
                                            .font(.system(size: 12))
                                            .foregroundStyle(
                                                RestyleColors.textSecondary
                                            )
                                            .fixedSize(
                                                horizontal: false,
                                                vertical: true
                                            )

                                        Text(
                                            "\(guide.minutes) min · \(guide.difficulty.capitalized) · \(guide.noSew ? "No sew" : "Sewing")"
                                        )
                                        .font(
                                            .system(
                                                size: 11,
                                                weight: .medium
                                            )
                                        )
                                        .foregroundStyle(
                                            RestyleColors.textSecondary
                                        )
                                    }

                                    Spacer(minLength: 0)

                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(
                                            RestyleColors.textPrimary
                                        )
                                }
                                .padding(14)
                                .background(
                                    Color.white,
                                    in: RoundedRectangle(
                                        cornerRadius: 16
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 20)
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
    }

    // MARK: - Step-by-Step Guide Screen

    private func guideScreen(
        _ guide: MyRepurposeGuide
    ) -> some View {

        VStack(alignment: .leading, spacing: 0) {

            HStack {

                // Back button opens custom bottom sheet
                backButton {
                    showLeave = true
                }

                Spacer()

                // Close button also opens custom bottom sheet
                Button {
                    showLeave = true
                } label: {

                    Image(systemName: "xmark")
                        .foregroundStyle(RestyleColors.textPrimary)
                        .frame(width: 44, height: 44)
                }
            }

            ScrollView {

                VStack(alignment: .leading, spacing: 16) {

                    Text(guide.title.uppercased())
                        .font(RestyleTypography.editorial(28))
                        .foregroundStyle(RestyleColors.textPrimary)

                    Text(guide.summary)
                        .font(.system(size: 13))
                        .foregroundStyle(RestyleColors.textSecondary)

                    garmentPhoto

                    // MARK: Materials and Tools

                    Text("YOU WILL NEED")
                        .font(
                            .system(
                                size: 14,
                                weight: .semibold
                            )
                        )

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 8
                    ) {

                        ForEach(
                            Array(
                                (guide.materials + guide.tools).enumerated()
                            ),
                            id: \.offset
                        ) { _, item in

                            Text(item)
                                .font(.system(size: 12))
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .padding(10)
                                .background(
                                    Color.white,
                                    in: RoundedRectangle(
                                        cornerRadius: 10
                                    )
                                )
                        }
                    }

                    // MARK: Instructions

                    Text("STEP-BY-STEP")
                        .font(
                            .system(
                                size: 14,
                                weight: .semibold
                            )
                        )
                        .padding(.top, 8)

                    ForEach(
                        Array(guide.steps.enumerated()),
                        id: \.offset
                    ) { index, step in

                        VStack(
                            alignment: .leading,
                            spacing: 9
                        ) {

                            HStack(spacing: 10) {

                                Text("\(index + 1)")
                                    .font(
                                        .system(
                                            size: 14,
                                            weight: .bold
                                        )
                                    )
                                    .frame(width: 30, height: 30)
                                    .background(
                                        RestyleColors.lime,
                                        in: Circle()
                                    )

                                Text(step.title)
                                    .font(
                                        .system(
                                            size: 14,
                                            weight: .semibold
                                        )
                                    )

                                Spacer()
                            }

                            Text(step.heading)
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .semibold
                                    )
                                )

                            Text(step.detail)
                                .font(.system(size: 13))
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )

                            Text("TIP: \(step.tip)")
                                .font(.system(size: 12))
                                .foregroundStyle(
                                    RestyleColors.textSecondary
                                )
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(14)
                        .background(
                            Color.white,
                            in: RoundedRectangle(
                                cornerRadius: 14
                            )
                        )
                    }

                    // MARK: Sustainability Benefit

                    Text(guide.benefit)
                        .font(.system(size: 12))
                        .foregroundStyle(
                            RestyleColors.textSecondary
                        )
                        .padding(.vertical, 12)
                }
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 20)

        .safeAreaInset(edge: .bottom) {

            primaryButton("I Finished This Guide") {
                screen = .complete
            }
        }
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
    }

    // MARK: - Selected Wardrobe Photo

    private var garmentPhoto: some View {

        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .overlay {

                if let id = garment.wardrobeGarmentID,
                   let saved = wardrobeStore.garments.first(
                       where: { $0.id == id }
                   ),
                   let photo = wardrobeStore.image(for: saved) {

                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .accessibilityLabel(saved.name)
                }
            }
            .frame(height: 150)
    }

    // MARK: - Project Completion Screen

    private var completionScreen: some View {

        VStack(alignment: .leading, spacing: 20) {

            Spacer()

            Text("PROJECT COMPLETE")
                .font(
                    .system(
                        size: 11,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    RestyleColors.textSecondary
                )

            Text("NEW PURPOSE.\nSAME FABRIC.")
                .font(RestyleTypography.editorial(42))
                .foregroundStyle(
                    RestyleColors.textPrimary
                )

            if let selectedGuide {

                Text("You completed: \(selectedGuide.title)")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        RestyleColors.textSecondary
                    )
            }

            Spacer()

            Image("Repurposeit")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 240)

            Spacer()

            primaryButton("Done") {
                dismiss()
            }
        }
        .padding(.horizontal, 24)
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
    }

    // MARK: - RISE Statistics Card

    private func outcomeCard(
        stat: OutcomeStat,
        source: GarmentOutcomes.Source
    ) -> some View {

        VStack(alignment: .leading, spacing: 7) {

            Text("FROM REAL DONATIONS")
                .font(
                    .system(
                        size: 10,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RestyleColors.textSecondary
                )

            Text(
                stat.counts.noLongerWornShare.formatted(
                    .percent.precision(.fractionLength(0))
                )
            )
            .font(RestyleTypography.editorial(30))

            Text(
                "of damaged garments in this dataset were remade, recycled, or sent for energy recovery."
            )
            .font(.system(size: 12))

            if let url = URL(string: source.url) {

                Link(
                    "Based on \(stat.counts.total.formatted()) garments · \(source.name)",
                    destination: url
                )
                .font(.system(size: 10))
                .foregroundStyle(
                    RestyleColors.textSecondary
                )
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(16)
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // MARK: - Custom Leave Guide Bottom Sheet

    private var leaveGuideSheet: some View {

        VStack(alignment: .leading, spacing: 0) {

            // Lime accent bar
            Capsule()
                .fill(RestyleColors.lime)
                .frame(width: 104, height: 10)
                .padding(.top, 40)

            Text("LEAVE THIS GUIDE?")
                .font(
                    .system(
                        size: 12,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RestyleColors.textSecondary
                )
                .padding(.top, 16)

            Text("Pause this project?")
                .font(RestyleTypography.editorial(34))
                .foregroundStyle(
                    RestyleColors.textPrimary
                )
                .padding(.top, 28)

            Text(
                "You can return to your Repurpose ideas. Completing a guide is always your choice."
            )
            .font(.system(size: 15))
            .foregroundStyle(
                RestyleColors.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .padding(.top, 24)

            Spacer(minLength: 20)

            // MARK: Keep Creating Button

            Button {

                showLeave = false

            } label: {

                Text("Keep Creating")
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        RestyleColors.textPrimary
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RestyleColors.lime,
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)

            // MARK: Leave Guide Button

            Button {

                showLeave = false

                // Return to personalized Repurpose ideas
                screen = .ideas

            } label: {

                Text("Leave Guide")
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        Color.red
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Color(
                            red: 0.94,
                            green: 0.94,
                            blue: 0.92
                        ),
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 24)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color.white)
    }

    // MARK: - Shared Back Button

    private func backButton(
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            Image(systemName: "chevron.left")
                .font(.system(size: 19))
                .foregroundStyle(
                    RestyleColors.textPrimary
                )
                .frame(width: 44, height: 44)
                .background(
                    RestyleColors.surfaceRaised,
                    in: RoundedRectangle(
                        cornerRadius: 14
                    )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Shared Primary Button

    private func primaryButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            Text(title)
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    RestyleColors.textPrimary
                )
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RestyleColors.lime,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RestyleColors.background
        )
    }
}
