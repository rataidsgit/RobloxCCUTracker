import Foundation

final class RobloxAPI {

    static let shared = RobloxAPI()

    private let session = URLSession.shared

    private init() {}

    // MARK: - User Games

    func getAllUserGames(userID: Int) async throws -> [RobloxGame] {

        var games: [RobloxGame] = []
        var cursor: String?

        repeat {

            var components = URLComponents(
                string:
                    "https://games.roblox.com/v2/users/\(userID)/games"
            )!

            var queryItems = [
                URLQueryItem(
                    name: "sortOrder",
                    value: "Asc"
                ),
                URLQueryItem(
                    name: "limit",
                    value: "50"
                )
            ]

            if let cursor {
                queryItems.append(
                    URLQueryItem(
                        name: "cursor",
                        value: cursor
                    )
                )
            }

            components.queryItems = queryItems

            let response: RobloxPagedGameResponse =
                try await get(components.url!)

            games.append(
                contentsOf: response.data.map {
                    $0.asGame
                }
            )

            cursor = response.nextPageCursor

        } while cursor != nil

        return games
    }


    // MARK: - Group Games

    func getAllGroupGames(
        groupID: Int
    ) async throws -> [RobloxGame] {

        var games: [RobloxGame] = []
        var cursor: String?

        repeat {

            var components = URLComponents(
                string:
                    "https://games.roblox.com/v2/groups/\(groupID)/games"
            )!

            var queryItems = [
                URLQueryItem(
                    name: "sortOrder",
                    value: "Asc"
                ),
                URLQueryItem(
                    name: "limit",
                    value: "50"
                )
            ]

            if let cursor {
                queryItems.append(
                    URLQueryItem(
                        name: "cursor",
                        value: cursor
                    )
                )
            }

            components.queryItems = queryItems

            let response: RobloxPagedGameResponse =
                try await get(components.url!)

            games.append(
                contentsOf: response.data.map {
                    $0.asGame
                }
            )

            cursor = response.nextPageCursor

        } while cursor != nil

        return games
    }


    // MARK: - Individual Game

    func getGame(
        universeID: Int
    ) async throws -> RobloxGame {

        let url = URL(
            string:
                "https://games.roblox.com/v1/games?universeIds=\(universeID)"
        )!

        let response: RobloxGameListResponse =
            try await get(url)

        guard let game = response.data.first else {
            throw RobloxAPIError.gameNotFound
        }

        return game.asGame
    }


    // MARK: - Current CCU

    func getCCU(
        universeID: Int
    ) async throws -> Int {

        let url = URL(
            string:
                "https://games.roblox.com/v1/games?universeIds=\(universeID)"
        )!

        let response: RobloxGameListResponse =
            try await get(url)

        guard let game = response.data.first else {
            throw RobloxAPIError.gameNotFound
        }

        return game.playing ?? 0
    }


    // MARK: - Multiple CCUs

    func getCCUs(
        universeIDs: [Int]
    ) async throws -> [Int: Int] {

        guard !universeIDs.isEmpty else {
            return [:]
        }

        // Roblox supports multiple universe IDs in one request.
        // Keep requests reasonably sized.

        let chunks = universeIDs.chunked(into: 50)

        var result: [Int: Int] = [:]

        for chunk in chunks {

            let ids = chunk
                .map(String.init)
                .joined(separator: ",")

            let url = URL(
                string:
                    "https://games.roblox.com/v1/games?universeIds=\(ids)"
            )!

            let response: RobloxGameListResponse =
                try await get(url)

            for game in response.data {

                result[game.id] =
                    game.playing ?? 0
            }
        }

        return result
    }


    // MARK: - Generic GET

    private func get<T: Decodable>(
        _ url: URL
    ) async throws -> T {

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let (data, response) =
            try await session.data(
                for: request
            )

        try validate(response)

        do {

            return try JSONDecoder().decode(
                T.self,
                from: data
            )

        } catch {

            throw RobloxAPIError.decodingError(
                error.localizedDescription
            )
        }
    }


    // MARK: - Validation

    private func validate(
        _ response: URLResponse
    ) throws {

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw RobloxAPIError.invalidResponse
        }

        guard (200...299).contains(
            httpResponse.statusCode
        ) else {

            throw RobloxAPIError.httpError(
                httpResponse.statusCode
            )
        }
    }
}


// MARK: - Discovery Response

private struct RobloxPagedGameResponse: Codable {

    let previousPageCursor: String?
    let nextPageCursor: String?
    let data: [RobloxDiscoveryGame]
}


private struct RobloxDiscoveryGame: Codable {

    let id: Int
    let name: String
    let rootPlaceId: Int?
    let creator: RobloxCreatorResponse?

    var asGame: RobloxGame {

        RobloxGame(
            id: id,
            name: name,
            rootPlaceId: rootPlaceId,
            creatorId: creator?.id,
            creatorName: creator?.name,
            currentCCU: 0
        )
    }
}


// MARK: - Game Details Response

private struct RobloxGameListResponse: Codable {

    let data: [RobloxGameResponse]
}


private struct RobloxGameResponse: Codable {

    let id: Int
    let name: String
    let rootPlaceId: Int?
    let playing: Int?
    let creator: RobloxCreatorResponse?

    var asGame: RobloxGame {

        RobloxGame(
            id: id,
            name: name,
            rootPlaceId: rootPlaceId,
            creatorId: creator?.id,
            creatorName: creator?.name,
            currentCCU: playing ?? 0
        )
    }
}


private struct RobloxCreatorResponse: Codable {

    let id: Int
    let name: String
}


// MARK: - Errors

enum RobloxAPIError: LocalizedError {

    case invalidResponse
    case httpError(Int)
    case gameNotFound
    case decodingError(String)

    var errorDescription: String? {

        switch self {

        case .invalidResponse:
            return "Roblox returned an invalid response."

        case .httpError(let statusCode):
            return "Roblox API returned HTTP \(statusCode)."

        case .gameNotFound:
            return "The requested Roblox game could not be found."

        case .decodingError(let message):
            return "Could not read Roblox's response:\n\(message)"
        }
    }
}


// MARK: - Array Helpers

private extension Array {

    func chunked(
        into size: Int
    ) -> [[Element] {

        guard size > 0 else {
            return [self]
        }

        return stride(
            from: 0,
            to: count,
            by: size
        ).map {

            Array(
                self[
                    $0..<Swift.min(
                        $0 + size,
                        count
                    )
                ]
            )
        }
    }
}