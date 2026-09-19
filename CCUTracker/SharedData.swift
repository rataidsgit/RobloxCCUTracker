import Foundation
import WidgetKit

struct SharedGame: Codable, Identifiable {

    let id: Int
    let name: String
    let currentCCU: Int

    var identity: Int {
        id
    }
}

struct SharedCCUData: Codable {

    let games: [SharedGame]
    let totalCCU: Int
    let updatedAt: Date

    static let empty =
        SharedCCUData(
            games: [],
            totalCCU: 0,
            updatedAt: .distantPast
        )
}

final class SharedDataStore {

    static let shared =
        SharedDataStore()

    private let suiteName =
        "group.com.robloxccutracker"

    private let dataKey =
        "sharedCCUData"

    private init() {}

    // MARK: - Save

    func save(
        games: [RobloxGame]
    ) {

        let sharedGames =
            games.map {

                SharedGame(
                    id: $0.id,
                    name: $0.name,
                    currentCCU:
                        $0.currentCCU
                )
            }

        let totalCCU =
            sharedGames.reduce(0) {
                $0 + $1.currentCCU
            }

        let data =
            SharedCCUData(
                games: sharedGames,
                totalCCU: totalCCU,
                updatedAt: Date()
            )

        save(
            data: data
        )
    }

    // MARK: - Save Shared Data

    func save(
        data: SharedCCUData
    ) {

        do {

            let encoded =
                try JSONEncoder()
                    .encode(data)

            UserDefaults(
                suiteName:
                    suiteName
            )?.set(
                encoded,
                forKey:
                    dataKey
            )

        } catch {

            print(
                "Failed to save shared CCU data:",
                error
            )
        }

        WidgetCenter.shared
            .reloadTimelines(
                ofKind:
                    "CCUTrackerWidget"
            )
    }

    // MARK: - Load

    func load() -> SharedCCUData {

        guard let encoded =
                UserDefaults(
                    suiteName:
                        suiteName
                )?.data(
                    forKey:
                        dataKey
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

            print(
                "Failed to decode shared CCU data:",
                error
            )

            return .empty
        }
    }
}