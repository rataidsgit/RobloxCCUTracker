import Foundation

@MainActor
final class SourceStore: ObservableObject {

    static let shared = SourceStore()

    @Published private(set) var sources: [RobloxSource] = []

    private let storageKey = "RobloxCCUTracker.sources"

    private init() {
        load()
    }

    // MARK: - Add

    func add(_ source: RobloxSource) {
        sources.append(source)
        save()
    }

    // MARK: - Update

    func update(_ source: RobloxSource) {

        guard let index = sources.firstIndex(
            where: { $0.id == source.id }
        ) else {
            return
        }

        sources[index] = source
        save()
    }

    // MARK: - Delete

    func delete(_ source: RobloxSource) {

        sources.removeAll {
            $0.id == source.id
        }

        save()
    }

    // MARK: - Save

    private func save() {

        do {

            let data = try JSONEncoder().encode(
                sources
            )

            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )

        } catch {

            print(
                "Failed to save sources:",
                error
            )
        }
    }

    // MARK: - Load

    private func load() {

        guard let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                )
        else {

            // First launch — use your current sources.
            sources = Self.defaultSources
            save()
            return
        }

        do {

            sources = try JSONDecoder().decode(
                [RobloxSource].self,
                from: data
            )

        } catch {

            print(
                "Failed to load sources:",
                error
            )

            sources = Self.defaultSources
        }
    }

    // MARK: - Default Sources

    private static let defaultSources: [RobloxSource] = [

        RobloxSource(
            type: .user,
            value: 71800600,
            name: "My Roblox Account"
        ),

        RobloxSource(
            type: .group,
            value: 6770993,
            name: "Mousetrap Studios"
        ),

        RobloxSource(
            type: .group,
            value: 35153760,
            name: "Mousetrap Brainrot"
        ),

        RobloxSource(
            type: .group,
            value: 35483952,
            name: "SUMMIT!"
        ),

        RobloxSource(
            type: .group,
            value: 34922411,
            name: "Mousetrap Midnight"
        )
    ]
}