
import SwiftUI

// MARK: - Return Home Environment Action

private struct RewearReturnHomeKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var rewearReturnHome: () -> Void {
        get { self[RewearReturnHomeKey.self] }
        set { self[RewearReturnHomeKey.self] = newValue }
    }
}

// MARK: - App Entry

@main
struct MyApp: App {

    @StateObject private var wardrobeStore = WardrobeStore()

    @State private var navigationID = UUID()

    var body: some Scene {
        WindowGroup {

            NavigationStack {
                ContentView()
            }
            .id(navigationID)
            .environmentObject(wardrobeStore)
            .environment(\.rewearReturnHome) {
                // Reset the NavigationStack to its root.
                navigationID = UUID()
            }
        }
    }
}
