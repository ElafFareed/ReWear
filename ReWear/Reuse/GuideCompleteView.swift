
import SwiftUI
import Foundation

struct GuideCompleteView: View {

    @Binding var path: NavigationPath

   

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Spacer()
                .frame(height: 95)

            Text("GUIDE COMPLETE")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.gray)

            Text("MENDED.\nREWORN.")
                .font(.system(size: 42, weight: .black))
                .italic()
                .foregroundStyle(.black)
                .lineSpacing(10)
                .padding(.top, 20)

            Image("finished")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 5)

            Spacer(minLength: 10)

            Button {
                // Return directly to the three cards
                path = NavigationPath()
            } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(
                        RestyleColors.lime,
                        in: Capsule()
                    )
                    .clipShape(Capsule())
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RestyleColors.background.ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        GuideCompleteView(
            path: .constant(NavigationPath())
        )
    }
}

