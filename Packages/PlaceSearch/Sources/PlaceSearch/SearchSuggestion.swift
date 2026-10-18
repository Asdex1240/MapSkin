public struct SearchSuggestion: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String

    public init(title: String, subtitle: String) {
        self.id = "\(title)|\(subtitle)"
        self.title = title
        self.subtitle = subtitle
    }
}
