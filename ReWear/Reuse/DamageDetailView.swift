// xcode: set sdk=iOS


import SwiftUI

struct DamageDetailView: View {
    @Environment(\.rewearReturnHome) private var returnHome
    let guideID: String
    @Binding var path: NavigationPath
    @Environment(\.dismiss) private var dismiss
    @State private var shouldReturnHome = false

    // Control the Leave Guide sheet
    @State private var showLeaveGuide = false

    private var guide: RepairGuide? {
        RepairData.loadGuides().first {
            $0.id == guideID
        }
    }

    private let blue = Color(
        red: 67.0 / 255.0,
        green: 119.0 / 255.0,
        blue: 254.0 / 255.0
    )

    private let lime = Color(
        red: 192.0 / 255.0,
        green: 254.0 / 255.0,
        blue: 15.0 / 255.0
    )

    // Images from Assets
    private var RepairImage: String {
        switch guideID {
        case "bleach_marks":
            return "bleach"

        case "stubborn_stains":
            return "Reclaim the stain"

        case "small_tears_holes":
            return "Mend in plain sight"

        case "missing_buttons":
            return "Buttobs and seam"

        default:
            return "Repair"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 1) {

                // Back and Close Buttons
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundStyle(.black)
                            .frame(width: 48, height: 48)
                            .background(Color.gray.opacity(0.08))
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                    }

                    Spacer()

                    // X Button
                    Button {
                        showLeaveGuide = true
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(.black)
                            .frame(width: 48, height: 48)
                            .background(Color.gray.opacity(0.08))
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                    }
                }

                if let guide = guide {

                    // Title from JSON
                    Text(guide.repair.title)
                        .font(.system(size: 28, weight: .black))
                        .italic()
                        .foregroundStyle(.black)

                    // Description from JSON
                    Text(guide.repair.summary)
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    // Images from Assets
                    Image(RepairImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 170)

                    // Materials from JSON
                    Text("YOU WILL NEED")
                        .padding(.bottom,9)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.black)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 15
                    ) {
                        ForEach(
                            Array(guide.repair.materials.enumerated()),
                            id: \.offset
                        ) { _, material in

                            Text(material)
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .medium
                                    )
                                )
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(.white)
                                .clipShape(Capsule())
                        }
                    }

                    // Steps Heading
                    Text("STEP-BY-STEP")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.top, 17)

                    // Steps from JSON
                    ForEach(guide.repair.steps) { step in

                        HStack(
                            alignment: .top,
                            spacing: 14
                        ) {

                            Text("\(step.stepNumber)")
                                .font(
                                    .system(
                                        size: 18,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(blue)
                                .clipShape(Circle())

                            Text(step.instruction)
                                .font(.system(size: 14))
                                .foregroundStyle(.black)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                        }
                        .padding(13)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .background(.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 13)
                        )
                        .shadow(
                            color: .black.opacity(0.05),
                            radius: 1,
                            y: 1
                        )
                    }

                    // Finish Button
                    NavigationLink {
                        GuideCompleteView(path: $path)
                    } label: {
                        Text("I Finished This Guide")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 19)
                            .background(lime)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 19)
                    .padding(.bottom, 10)
                } else {
                    Text("Guide not found")
                        .font(.title2.bold())

                    Text("Check the ID in repairGuides.json.")
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 16)
        }
        .background(RestyleColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)

        // Leave Guide Sheet
        .sheet(
            isPresented: $showLeaveGuide,
            onDismiss: {
                if shouldReturnHome {
                    shouldReturnHome = false
                    returnHome()
                }
            }
        ) {
            VStack(alignment: .leading, spacing: 24) {

                // Blue progress line
                Capsule()
                    .fill(blue)
                    .frame(width: 65, height: 6)

                Text("LEAVE THIS GUIDE?")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.black)

                Text("Pause this repair?")
                    .font(.system(size: 25, weight: .black))
                    .italic()
                    .foregroundStyle(.black)

                Text("You can return to the damage list. Completing a guide is always your choice.")
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)

                Spacer(minLength: 5)

                // Keep Repairing Button
                Button {
                    showLeaveGuide = false
                } label: {
                    Text("Keep Repairing")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(lime)
                        .clipShape(Capsule())
                }

                // Leave Guide Button
                Button {
                    showLeaveGuide = false
                    returnHome()
                } label: {
                    Text("Leave Guide")                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.red.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            Color(
                                red: 228.0 / 255.0,
                                green: 228.0 / 255.0,
                                blue: 226.0 / 255.0
                            )
                        )
                        .clipShape(Capsule())
                }
            }
            .padding(24)
            .padding(.top, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color(
                    red: 250.0 / 255.0,
                    green: 249.0 / 255.0,
                    blue: 247.0 / 255.0
                )
            )
            .presentationDetents([.medium])
        }
    }
}
#Preview {
    NavigationStack {
        DamageDetailView(
            guideID: "bleach_marks",
            path: .constant(NavigationPath())
        )
    }
}

