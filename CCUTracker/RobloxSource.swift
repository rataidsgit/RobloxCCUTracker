import Foundation

enum RobloxSourceType: String, Codable, CaseIterable, Identifiable {
    case user
    case group
    case game

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .user:
            return "User"
        case .group:
            return "Group"
        case .game:
            return "Game"
        }
    }
}

struct RobloxSource: Identifiable, Codable, Hashable {
    let id: UUID
    var type: RobloxSourceType
    var value: Int
    var name: String

    init(
        id: UUID = UUID(),
        type: RobloxSourceType,
        value: Int,
        name: String
    ) {
        self.id = id
        self.type = type
        self.value = value
        self.name = name
    }
}