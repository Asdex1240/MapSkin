import Foundation

extension URL {
    var filePath: String {
        path(percentEncoded: false)
    }
}
