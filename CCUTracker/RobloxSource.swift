import Foundation

enum RobloxSourceType: String, Codable {
    case user
    case group
    case game
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