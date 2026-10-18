import AppUI
import SwiftUI

@main
struct MapSkinApp: App {
    private let configuration = AppConfiguration(bundle: .main)

    var body: some Scene {
        WindowGroup {
            HomeView(mapStyleURL: configuration.mapStyleURL)
        }
    }
}
