import WidgetKit
import SwiftUI

struct CCUEntry: TimelineEntry {
    let date: Date
    let totalCCU: Int
}

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> CCUEntry {
        CCUEntry(
            date: Date(),
            totalCCU: 1795
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (CCUEntry) -> Void
    ) {
        completion(
            CCUEntry(
                date: Date(),
                totalCCU: 1795
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<CCUEntry>) -> Void
    ) {
        let entry = CCUEntry(
            date: Date(),
            totalCCU: 1795
        )

        let nextUpdate = Calendar.current.date(
            byAdding: .minute,
            value: 15,
            to: Date()
        )!

        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdate)
        )

        completion(timeline)
    }
}

struct CCUTrackerWidgetView: View {

    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("🎮")
                .font(.title2)

            Text("\(entry.totalCCU)")
                .font(.system(size: 22, weight: .bold))

            Text("CCU")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.background, for: .widget)
    }
}

struct CCUTrackerWidget: Widget {

    let kind = "CCUTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            CCUTrackerWidgetView(entry: entry)
        }
        .configurationDisplayName("Roblox CCU")
        .description("Shows your combined Roblox CCU.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .systemSmall
        ])
    }
}

@main
struct CCUTrackerWidgetBundle: WidgetBundle {

    var body: some Widget {
        CCUTrackerWidget()
    }
}