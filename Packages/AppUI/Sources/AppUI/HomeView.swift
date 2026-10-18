import MapRendering
import SwiftUI
import TexturePacks

public struct HomeView: View {
    private struct SkinRequest: Hashable {
        let packID: TexturePack.ID
        let appearance: MapAppearance
        let screenScale: Double
    }

    private static let maximumCollapsedSheetHeight = 320.0
    private static let ornamentSpacing = 16.0

    @State private var model: HomeModel
    @State private var skinStore: MapSkinStore
    @State private var importFlow: TexturePackImportFlow
    @State private var isSettingsPresented = false
    @State private var isFollowingUser = true
    @State private var recenterRequest = 0
    @State private var navigationBarHeight = 110.0
    @State private var sheetPosition = SheetPosition.collapsed
    @ScaledMetric(relativeTo: .body) private var scaledCollapsedSheetHeight = 196.0
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    public init(dependencies: HomeDependencies) {
        _model = State(initialValue: HomeModel(dependencies: dependencies))
        let skinStore = MapSkinStore(factory: dependencies.skinFactory, library: dependencies.textureLibrary)
        _skinStore = State(initialValue: skinStore)
        let importFlow = TexturePackImportFlow(library: dependencies.textureLibrary, defaults: dependencies.defaults)
        _importFlow = State(initialValue: importFlow)
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
                        ActiveNavigationView(model: model) { navigationBarHeight = $0 }
                    }
                }
        }
        .sheet(isPresented: .constant(!model.isNavigating)) {
            sheetContent
                .presentationDetents([collapsedDetent, .medium, .large], selection: detentSelection)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .texturePackImportAlerts(importFlow, isActive: !isSettingsPresented)
                .sheet(isPresented: $isSettingsPresented) {
                    SettingsView(flow: importFlow)
                }
        }
        .onOpenURL { url in
            Task { await importFlow.receive(url) }
        }
        .task(id: skinRequest) {
            await skinStore.loadSkin(for: skinRequest.appearance, screenScale: skinRequest.screenScale)
        }
        .task {
            await model.prepare()
        }
        .onChange(of: model.planning?.place) { _, place in
            sheetPosition = place == nil ? .collapsed : .medium
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
            SearchPanel(
                model: model,
                onFocus: { sheetPosition = .large },
                onOpenSettings: { isSettingsPresented = true }
            )
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
        model.isNavigating ? navigationBarHeight + Self.ornamentSpacing : collapsedSheetHeight
    }

    private var collapsedSheetHeight: Double {
        min(scaledCollapsedSheetHeight, Self.maximumCollapsedSheetHeight)
    }

    private var collapsedDetent: PresentationDetent {
        SheetPosition.collapsed.detent(collapsedHeight: collapsedSheetHeight)
    }

    private var detentSelection: Binding<PresentationDetent> {
        Binding(
            get: { sheetPosition.detent(collapsedHeight: collapsedSheetHeight) },
            set: { sheetPosition = SheetPosition($0) }
        )
    }

    private var skinRequest: SkinRequest {
        SkinRequest(
            packID: importFlow.library.activePackID,
            appearance: MapAppearance(colorScheme),
            screenScale: displayScale
        )
    }

    private func overviewPadding(for size: CGSize) -> UIEdgeInsets {
        UIEdgeInsets(top: 80, left: 40, bottom: size.height * 0.5 + 24, right: 40)
    }
}
