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
                string: "https://games.roblox.com/v2/users/\(userID)/games"
            )!

            var queryItems = [
                URLQueryItem(name: "sortOrder", value: "Asc"),
                URLQueryItem(name: "limit", value: "50")
            ]

            if let cursor {
                queryItems.append(
                    URLQueryItem(name: "cursor", value: cursor)
                )
            }

            components.queryItems = queryItems

            let response: RobloxPagedGameResponse =
                try await get(components.url!)

            games.append(contentsOf: response.data)
            cursor = response.nextPageCursor

        } while cursor != nil

        return games.map { $0.asGame }
    }

    // MARK: - Group Games

    func getAllGroupGames(groupID: Int) async throws -> [RobloxGame] {
        var games: [RobloxGame] = []
        var cursor: String?

        repeat {
            var components = URLComponents(
                string: "https://games.roblox.com/v2/groups/\(groupID)/games"
            )!

            var queryItems = [
                URLQueryItem(name: "sortOrder", value: "Asc"),
                URLQueryItem(name: "limit", value: "50")
            ]

            if let cursor {
                queryItems.append(
                    URLQueryItem(name: "cursor", value: cursor)
                )
            }

            components.queryItems = queryItems

            let response: RobloxPagedGameResponse =
                try await get(components.url!)

            games.append(contentsOf: response.data)
            cursor = response.nextPageCursor

        } while cursor != nil

        return games.map { $0.asGame }
    }

    // MARK: - Individual Game

    func getGame(universeID: Int) async throws -> RobloxGame {
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

    func getCCU(universeID: Int) async throws -> Int {
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

        let ids = universeIDs
            .map(String.init)
            .joined(separator: ",")

        let url = URL(
            string:
                "https://games.roblox.com/v1/games?universeIds=\(ids)"
        )!

        let response: RobloxGameListResponse =
            try await get(url)

        var result: [Int: Int] = [:]

        for game in response.data {
            result[game.id] = game.playing ?? 0
        }

        return result
    }

    // MARK: - Generic GET

    private func get<T: Decodable>(
        _ url: URL
    ) async throws -> T {

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) =
            try await session.data(for: request)

        try validate(response)

        return try JSONDecoder().decode(
            T.self,
            from: data
        )
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


// MARK: - API Responses

private struct RobloxPagedGameResponse: Codable {

    let previousPageCursor: String?
    let nextPageCursor: String?
    let data: [RobloxGameResponse]
}

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

enum RobloxAPIError: Error {

    case invalidResponse
    case httpError(Int)
    case gameNotFound
}