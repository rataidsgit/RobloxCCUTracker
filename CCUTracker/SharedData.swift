import Foundation

struct SharedGame: Codable, Identifiable {
    let id: Int
    let name: String
    let currentCCU: Int
}

struct SharedCCUData: Codable {

    let games: [SharedGame]
    let totalCCU: Int
    let updatedAt: Date

    static let empty = SharedCCUData(
        games: [],
        totalCCU: 0,
        updatedAt: .distantPast
    )
}

final class SharedDataStore {

    static let shared = SharedDataStore()

    private let suiteName =
        "group.com.robloxccutracker"

    private let dataKey =
        "sharedCCUData"

    private init() {}

    func save(games: [RobloxGame]) {

        let sharedGames =
            games.map {
                SharedGame(
                    id: $0.id,
                    name: $0.name,
                    currentCCU: $0.currentCCU
                )
            }

        let total =
            sharedGames.reduce(0) {
                $0 + $1.currentCCU
            }

        let data = SharedCCUData(
            games: sharedGames,
            totalCCU: total,
            updatedAt: Date()
        )

        do {

            let encoded =
                try JSONEncoder().encode(data)

            UserDefaults(
                suiteName: suiteName
            )?.set(
                encoded,
                forKey: dataKey
            )

        } catch {

            print(
                "Failed to save shared CCU data:",
                error
            )
        }
    }
}