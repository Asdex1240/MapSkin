import SwiftUI

public struct HomeView: View {
    private let mapStyleURL: URL

    public init(mapStyleURL: URL) {
        self.mapStyleURL = mapStyleURL
    }

    public var body: some View {
        MapSkinRepresentable(styleURL: mapStyleURL)
            .ignoresSafeArea()
    }
}
