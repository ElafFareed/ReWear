
import SwiftUI

struct MyWardrobeView: View {

    @EnvironmentObject private var wardrobeStore: WardrobeStore

    // Nil = normal wardrobe browsing.
    // Not nil = select a garment for Repurpose.
    var onSelectGarment: ((Garment) -> Void)? = nil

    var body: some View {
        Group {
            if wardrobeStore.garments.isEmpty {

                EmptyWardrobeView()

            } else {

                SavedWardrobeView(
                    onSelectGarment: onSelectGarment
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MyWardrobeView()
    }
    .environmentObject(WardrobeStore())
}

