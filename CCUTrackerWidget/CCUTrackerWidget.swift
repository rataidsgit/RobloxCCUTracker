import WidgetKit
import SwiftUI

struct CCUEntry: TimelineEntry {

    let date: Date
    let totalCCU: Int
    let updatedAt: Date
}

struct Provider: TimelineProvider {

    private let store =
        SharedWidgetDataStore()

    func placeholder(
        in context: Context
    ) -> CCUEntry {

        CCUEntry(
            date: Date(),
            totalCCU: 0,
            updatedAt: .distantPast
        )
    }

    func getSnapshot(
        in context: Context,
        completion:
            @escaping (CCUEntry) -> Void
    ) {

        let data =
            store.load()

        completion(
            CCUEntry(
                date: Date(),
                totalCCU: data.totalCCU,
                updatedAt: data.updatedAt
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion:
            @escaping (
                Timeline<CCUEntry>
            ) -> Void
    ) {

        let data =
            store.load()

        let entry =
            CCUEntry(
                date: Date(),
                totalCCU: data.totalCCU,
                updatedAt: data.updatedAt
            )

        let nextUpdate =
            Calendar.current.date(
                byAdding: .minute,
                value: 15,
                to: Date()
            )!

        let timeline =
            Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            )

        completion(timeline)
    }
}


// MARK: - Widget Shared Storage

private final class SharedWidgetDataStore {

    private let suiteName =
        "group.com.robloxccutracker"

    private let dataKey =
        "sharedCCUData"

    func load() -> SharedCCUData {

        guard let encoded =
                UserDefaults(
                    suiteName: suiteName
                )?.data(
                    forKey: dataKey
                )
        else {

            return .empty
        }

        do {

            return try JSONDecoder()
                .decode(
                    SharedCCUData.self,
                    from: encoded
                )

        } catch {

            return .empty
        }
    }
}


// MARK: - Widget View

struct CCUTrackerWidgetView: View {

    var entry: CCUEntry

    var body: some View {

        Link(
            destination: URL(
                string: "robloxccu://"
            )!
        ) {

            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                Text("ROBLOX")
                    .font(.caption2)
                    .fontWeight(.semibold)

                Text(
                    entry.totalCCU.formatted()
                )
                .font(
                    .system(
                        size: 22,
                        weight: .bold
                    )
                )
                .monospacedDigit()

                Text("CCU")
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .leading
            )
        }
        .containerBackground(
            .background,
            for: .widget
        )
    }
}


// MARK: - Widget

struct CCUTrackerWidget: Widget {

    let kind =
        "CCUTrackerWidget"

    var body: some WidgetConfiguration {

        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in

            CCUTrackerWidgetView(
                entry: entry
            )
        }

        .configurationDisplayName(
            "Roblox CCU"
        )

        .description(
            "Shows your combined Roblox CCU."
        )

        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .systemSmall
        ])
    }
}


@main
struct CCUTrackerWidgetBundle:
    WidgetBundle {

    var body: some Widget {

        CCUTrackerWidget()
    }
}