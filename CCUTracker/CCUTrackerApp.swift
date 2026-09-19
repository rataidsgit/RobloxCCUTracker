import SwiftUI
import BackgroundTasks

@main
struct CCUTrackerApp: App {

    @UIApplicationDelegateAdaptor(
        AppDelegate.self
    )
    private var appDelegate

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

// MARK: - App Delegate

final class AppDelegate:
    NSObject,
    UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?
            = nil
    ) -> Bool {

        BackgroundRefreshService.shared.register()

        return true
    }

    func applicationDidEnterBackground(
        _ application: UIApplication
    ) {

        BackgroundRefreshService.shared.schedule()
    }
}