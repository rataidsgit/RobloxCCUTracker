import Foundation

struct RobloxGame: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let rootPlaceId: Int?
    let creatorId: Int?
    let creatorName: String?
    
    var currentCCU: Int = 0
}