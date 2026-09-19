import SwiftUI

@main
struct CCUTrackerApp: App {

    var body: some Scene {

        WindowGroup {

            ContentView()
                .onOpenURL { url in

                    handleURL(url)
                }
        }
    }

    private func handleURL(
        _ url: URL
    ) {

        guard url.scheme == "robloxccu"
        else {
            return
        }

        // The widget currently only needs
        // to open the main app.
        //
        // We can later use this to navigate
        // directly to specific screens.
    }
}