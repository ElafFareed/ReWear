
import SwiftUI
import Foundation

struct RepairView: View {

    @Binding var path: NavigationPath

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {

                // Back Button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Title
                VStack(alignment: .leading, spacing: 7) {
                    Text("WHAT'S THE\nDAMAGE?")
                        .font(.system(size: 35, weight: .black))
                        .italic()
                        .foregroundStyle(.black)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Select the type of damage to see its guide.\nNo photo or description needed.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Damage Options
                VStack(spacing: 13) {

                    NavigationLink {
                        DamageDetailView(
                            guideID: "bleach_marks",
                            path: $path
                        )
                    } label: {
                        DamageCard(
                            title: "Bleach Marks",
                            description: "Color loss or small bleached areas."
                        )
                    }

                    NavigationLink {
                        DamageDetailView(
                            guideID: "stubborn_stains",
                            path: $path
                        )
                    } label: {
                        DamageCard(
                            title: "Stubborn Stains",
                            description: "Marks that cannot be washed away."
                        )
                    }

                    NavigationLink {
                        DamageDetailView(
                            guideID: "small_tears_holes",
                            path: $path
                        )
                    } label: {
                        DamageCard(
                            title: "Small Tears & Holes",
                            description: "Minor tears, punctures or tiny holes."
                        )
                    }

                    NavigationLink {
                        DamageDetailView(
                            guideID: "missing_buttons",
                            path: $path
                        )
                    } label: {
                        DamageCard(
                            title: "Missing Buttons",
                            description: "A loose, missing or damaged button."
                        )
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
            .padding(.top, 16)
            .padding(.bottom, 25)
        }
        .background(RestyleColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// Damage Card
struct DamageCard: View {

    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 0) {

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.20, green: 0.42, blue: 1.0))
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 35) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)

                Text(description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 15)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
                .padding(.trailing, 17)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .padding(.vertical, 5)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 1))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

#Preview {
    NavigationStack {
        RepairView(path: .constant(NavigationPath()))
    }
}

