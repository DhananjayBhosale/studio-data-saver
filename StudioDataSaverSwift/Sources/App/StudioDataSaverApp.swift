import SwiftUI

@main
struct StudioDataSaverApp: App {
    @State private var store: StudioStore

    @MainActor
    init() {
        _store = State(initialValue: StudioStore())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .frame(minWidth: 1180, minHeight: 740)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
