import SwiftUI
import TexturePacks

extension MapAppearance {
    init(_ colorScheme: ColorScheme) {
        self = colorScheme == .dark ? .night : .day
    }
}
