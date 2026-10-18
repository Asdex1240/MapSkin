import MapStyle
import SwiftUI
import TexturePacks

public struct HomeView: View {
    private struct SkinRequest: Hashable {
        let appearance: MapAppearance
        let screenScale: Double
    }

    @State private var skinStore: MapSkinStore
    @State private var isFollowingUser = true
    @State private var recenterRequest = 0
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    public init(skinFactory: MapSkinFactory, texturePack: TexturePack) {
        _skinStore = State(initialValue: MapSkinStore(factory: skinFactory, pack: texturePack))
    }

    public var body: some View {
        map
            .ignoresSafeArea()
            .overlay(alignment: .bottomTrailing) {
                if !isFollowingUser {
                    RecenterButton { recenterRequest += 1 }
                        .padding(.trailing, 16)
                        .padding(.bottom, 56)
                }
            }
            .overlay(alignment: .bottom) {
                MapAttributionLabel()
                    .padding(.bottom, 8)
            }
            .task(id: skinRequest) {
                await skinStore.loadSkin(for: skinRequest.appearance, screenScale: skinRequest.screenScale)
            }
    }

    @ViewBuilder
    private var map: some View {
        if let skin = skinStore.skin {
            MapSkinRepresentable(skin: skin, recenterRequest: recenterRequest, isFollowingUser: $isFollowingUser)
        } else {
            Color(uiColor: .systemBackground)
        }
    }

    private var skinRequest: SkinRequest {
        SkinRequest(appearance: MapAppearance(colorScheme), screenScale: displayScale)
    }
}
