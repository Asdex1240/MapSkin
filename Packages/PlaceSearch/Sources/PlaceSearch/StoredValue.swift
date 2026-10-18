import Foundation
import OSLog

struct StoredValue<Value: Codable> {
    private let defaults: UserDefaults
    private let key: String
    private let logger = Logger(subsystem: "MapSkin", category: "StoredValue")

    init(defaults: UserDefaults, key: String) {
        self.defaults = defaults
        self.key = key
    }

    func load() -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(Value.self, from: data)
        } catch {
            logger.error("Discarding unreadable value for \(key): \(error.localizedDescription)")
            return nil
        }
    }

    func save(_ value: Value) {
        do {
            defaults.set(try JSONEncoder().encode(value), forKey: key)
        } catch {
            logger.error("Could not save value for \(key): \(error.localizedDescription)")
        }
    }
}
