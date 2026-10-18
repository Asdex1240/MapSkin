import MapRendering
import SwiftUI
import TexturePacks

public struct HomeView: View {
    private struct SkinRequest: Hashable {
        let appearance: MapAppearance
        let screenScale: Double
    }

    private static let collapsedSheetHeight = 150.0
    private static let collapsedDetent = PresentationDetent.height(collapsedSheetHeight)
    private static let navigationBarInset = 110.0

    @State private var model: HomeModel
    @State private var skinStore: MapSkinStore
    @State private var isFollowingUser = true
    @State private var recenterRequest = 0
    @State private var sheetDetent = Self.collapsedDetent
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    public init(dependencies: HomeDependencies) {
        _model = State(initialValue: HomeModel(dependencies: dependencies))
        let skinStore = MapSkinStore(factory: dependencies.skinFactory, pack: dependencies.texturePack)
        _skinStore = State(initialValue: skinStore)
    }

    public var body: some View {
        GeometryReader { proxy in
            map(overviewPadding: overviewPadding(for: proxy.size))
                .ignoresSafeArea()
                .overlay(alignment: .bottomTrailing) { recenterButton }
                .overlay(alignment: .bottom) {
                    MapAttributionLabel()
                        .padding(.bottom, bottomOrnamentInset + 8)
                }
                .overlay {
                    if model.isNavigating {
                        ActiveNavigationView(model: model)
                    }
                }
        }
        .sheet(isPresented: .constant(!model.isNavigating)) {
            sheetContent
                .presentationDetents([Self.collapsedDetent, .medium, .large], selection: $sheetDetent)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
        }
        .task(id: skinRequest) {
            await skinStore.loadSkin(for: skinRequest.appearance, screenScale: skinRequest.screenScale)
        }
        .task {
            await model.prepare()
        }
        .onChange(of: model.planning?.place) { _, place in
            sheetDetent = place == nil ? Self.collapsedDetent : .medium
        }
        .onChange(of: model.isNavigating) { _, isNavigating in
            UIApplication.shared.isIdleTimerDisabled = isNavigating
        }
    }

    @ViewBuilder
    private var sheetContent: some View {
        if let planning = model.planning {
            RoutePreviewPanel(model: model, state: planning)
        } else {
            SearchPanel(model: model) {
                sheetDetent = .large
            }
        }
    }

    @ViewBuilder
    private func map(overviewPadding: UIEdgeInsets) -> some View {
        if let skin = skinStore.skin {
            MapSkinRepresentable(
                skin: skin,
                overlay: model.routeOverlay,
                cameraMode: model.cameraMode,
                overviewPadding: overviewPadding,
                bottomOrnamentInset: bottomOrnamentInset,
                navigationSample: model.navigation.progress?.location,
                recenterRequest: recenterRequest,
                isFollowingUser: $isFollowingUser
            )
        } else {
            Color(uiColor: .systemBackground)
        }
    }

    @ViewBuilder
    private var recenterButton: some View {
        if !isFollowingUser && model.cameraMode == .followingUser {
            RecenterButton { recenterRequest += 1 }
                .padding(.trailing, 16)
                .padding(.bottom, bottomOrnamentInset + 48)
        }
    }

    private var bottomOrnamentInset: Double {
        model.isNavigating ? Self.navigationBarInset : Self.collapsedSheetHeight
    }

    private var skinRequest: SkinRequest {
        SkinRequest(appearance: MapAppearance(colorScheme), screenScale: displayScale)
    }

    private func overviewPadding(for size: CGSize) -> UIEdgeInsets {
        UIEdgeInsets(top: 80, left: 40, bottom: size.height * 0.5 + 24, right: 40)
    }
}
