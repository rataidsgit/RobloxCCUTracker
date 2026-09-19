import Foundation

final class RobloxAPI {

    static let shared = RobloxAPI()

    private let session = URLSession.shared

    private init() {}

    // MARK: - User Games

    func getUserGames(userID: Int) async throws -> [RobloxGame] {

        let url = URL(
            string: "https://games.roblox.com/v2/users/\(userID)/games"
        )!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)

        try validate(response)

        let result = try JSONDecoder().decode(
            RobloxGameListResponse.self,
            from: data
        )

        return result.data.map {
            RobloxGame(
                id: $0.id,
                name: $0.name,
                rootPlaceId: $0.rootPlaceId,
                creatorId: $0.creator?.id,
                creatorName: $0.creator?.name
            )
        }
    }

    // MARK: - Group Games

    func getGroupGames(groupID: Int) async throws -> [RobloxGame] {

        let url = URL(
            string: "https://games.roblox.com/v2/groups/\(groupID)/games"
        )!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)

        try validate(response)

        let result = try JSONDecoder().decode(
            RobloxGameListResponse.self,
            from: data
        )

        return result.data.map {
            RobloxGame(
                id: $0.id,
                name: $0.name,
                rootPlaceId: $0.rootPlaceId,
                creatorId: $0.creator?.id,
                creatorName: $0.creator?.name
            )
        }
    }

    // MARK: - Individual Game

    func getGame(universeID: Int) async throws -> RobloxGame {

        let url = URL(
            string: "https://games.roblox.com/v1/games?universeIds=\(universeID)"
        )!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)

        try validate(response)

        let result = try JSONDecoder().decode(
            RobloxGameListResponse.self,
            from: data
        )

        guard let game = result.data.first else {
            throw RobloxAPIError.gameNotFound
        }

        return RobloxGame(
            id: game.id,
            name: game.name,
            rootPlaceId: game.rootPlaceId,
            creatorId: game.creator?.id,
            creatorName: game.creator?.name
        )
    }

    // MARK: - Helpers

    private func validate(_ response: URLResponse) throws {

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RobloxAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw RobloxAPIError.httpError(httpResponse.statusCode)
        }
    }
}


// MARK: - Response Models

private struct RobloxGameListResponse: Codable {

    let data: [RobloxGameResponse]
}

private struct RobloxGameResponse: Codable {

    let id: Int
    let name: String
    let rootPlaceId: Int?
    let creator: RobloxCreatorResponse?
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