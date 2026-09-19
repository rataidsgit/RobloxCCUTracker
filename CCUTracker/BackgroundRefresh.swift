import Foundation
import BackgroundTasks
import WidgetKit

final class BackgroundRefreshService {

    static let shared = BackgroundRefreshService()

    static let taskIdentifier =
        "com.robloxccutracker.refresh"

    private init() {}

    // MARK: - Register

    func register() {

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in

            guard let refreshTask =
                    task as? BGAppRefreshTask
            else {
                task.setTaskCompleted(success: false)
                return
            }

            self.handle(
                refreshTask
            )
        }
    }

    // MARK: - Schedule

    func schedule() {

        BGTaskScheduler.shared.cancel(
            taskRequestWithIdentifier:
                Self.taskIdentifier
        )

        let request =
            BGAppRefreshTaskRequest(
                identifier:
                    Self.taskIdentifier
            )

        // Ask iOS to run this no earlier
        // than 15 minutes from now.
        //
        // iOS ultimately decides the actual
        // execution time.

        request.earliestBeginDate =
            Date(
                timeIntervalSinceNow:
                    15 * 60
            )

        do {

            try BGTaskScheduler.shared.submit(
                request
            )

            print(
                "Background CCU refresh scheduled."
            )

        } catch {

            print(
                "Failed to schedule background refresh:",
                error
            )
        }
    }

    // MARK: - Handle Task

    private func handle(
        _ task: BGAppRefreshTask
    ) {

        // Always schedule the next refresh.
        schedule()

        // If iOS gives us limited time,
        // cancel our work when it expires.

        let operation =
            Task {

                do {

                    let sources =
                        await MainActor.run {

                            SourceStore.shared.sources
                        }

                    let discovery =
                        GameDiscoveryService.shared

                    let games =
                        try await discovery
                            .discoverGames(
                                from: sources
                            )

                    let refreshed =
                        try await discovery
                            .refreshCCU(
                                for: games
                            )

                    SharedDataStore.shared.save(
                        games: refreshed
                    )

                    task.setTaskCompleted(
                        success: true
                    )

                } catch {

                    print(
                        "Background CCU refresh failed:",
                        error
                    )

                    task.setTaskCompleted(
                        success: false
                    )
                }
            }

        task.expirationHandler = {

            operation.cancel()

            task.setTaskCompleted(
                success: false
            )
        }
    }
}