import Foundation

final class GameDiscoveryService {

    static let shared = GameDiscoveryService()

    private let api = RobloxAPI.shared

    private init() {}

    func discoverGames(
        from sources: [RobloxSource]
    ) async throws -> [RobloxGame] {

        var gamesByID: [Int: RobloxGame] = [:]

        for source in sources {

            let games: [RobloxGame]

            switch source.type {

            case .user:
                games = try await api.getAllUserGames(
                    userID: source.value
                )

            case .group:
                games = try await api.getAllGroupGames(
                    groupID: source.value
                )

            case .game:
                games = [
                    try await api.getGame(
                        universeID: source.value
                    )
                ]
            }

            for game in games {
                gamesByID[game.id] = game
            }
        }

        return Array(gamesByID.values)
            .sorted {
                $0.name.localizedCaseInsensitiveCompare(
                    $1.name
                ) == .orderedAscending
            }
    }

    func refreshCCU(
        for games: [RobloxGame]
    ) async throws -> [RobloxGame] {

        let universeIDs = games.map(\.id)

        let ccu = try await api.getCCUs(
            universeIDs: universeIDs
        )

        return games.map { game in

            var updatedGame = game

            updatedGame.currentCCU =
                ccu[game.id] ?? 0

            return updatedGame
        }
    }
}