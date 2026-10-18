import Foundation

public struct Favorite: Identifiable, Hashable, Codable, Sendable {
    public enum Role: String, Codable, Sendable {
        case home
        case work
        case custom
    }

    public let id: UUID
    public let role: Role
    public let place: Place

    public init(id: UUID = UUID(), role: Role, place: Place) {
        self.id = id
        self.role = role
        self.place = place
    }
}
