import CarPlay
import MapRendering
import MapStyle
import NavigationCore
import OSLog
import TexturePacks
import UIKit

@MainActor
final class CarPlayMapViewController: UIViewController {
    private static let zoomStep = 1.0
    private static let panFraction = 0.33
    private static let guidancePanelFraction = 0.45

    private let skinFactory: MapSkinFactory
    private let library: TexturePackLibrary
    private let logger = Logger(subsystem: "MapSkin", category: "CarPlayMapViewController")
    private var mapView: MapSkinView?
    private var overlay = RouteOverlay.empty
    private var cameraMode = MapCameraMode.followingUser
    private var packObservation: ObservedValue<TexturePack.ID>?
    private var skinTask: Task<Void, Never>?

    init(skinFactory: MapSkinFactory, library: TexturePackLibrary) {
        self.skinFactory = skinFactory
        self.library = library
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (controller: CarPlayMapViewController, _) in
            controller.reloadSkin()
        }
        packObservation = ObservedValue({ [library] in library.activePackID }) { [weak self] _ in
            self?.reloadSkin()
        }
    }

    func stopObserving() {
        packObservation?.cancel()
        skinTask?.cancel()
    }

    func show(_ newOverlay: RouteOverlay) {
        overlay = newOverlay
        mapView?.show(newOverlay)
    }

    func setCameraMode(_ mode: MapCameraMode) {
        cameraMode = mode
        mapView?.setContentInset(contentInset(for: mode))
        mapView?.setCameraMode(mode, overviewPadding: overviewPadding)
    }

    func moveNavigationCamera(to sample: LocationSample) {
        mapView?.moveNavigationCamera(to: sample)
    }

    func recenter() {
        cameraMode = .followingUser
        mapView?.followUserLocation()
    }

    func zoomIn() {
        mapView?.zoom(by: Self.zoomStep)
    }

    func zoomOut() {
        mapView?.zoom(by: -Self.zoomStep)
    }

    func pan(_ direction: CPMapTemplate.PanDirection) {
        let horizontal = view.bounds.width * Self.panFraction
        let vertical = view.bounds.height * Self.panFraction
        var offset = CGPoint.zero
        if direction.contains(.left) { offset.x -= horizontal }
        if direction.contains(.right) { offset.x += horizontal }
        if direction.contains(.up) { offset.y -= vertical }
        if direction.contains(.down) { offset.y += vertical }
        mapView?.pan(by: offset)
    }

    private func contentInset(for mode: MapCameraMode) -> UIEdgeInsets {
        guard mode == .navigation else { return .zero }
        let panelWidth = view.bounds.width * Self.guidancePanelFraction
        return view.effectiveUserInterfaceLayoutDirection == .rightToLeft
            ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: panelWidth)
            : UIEdgeInsets(top: 0, left: panelWidth, bottom: 0, right: 0)
    }

    private var overviewPadding: UIEdgeInsets {
        UIEdgeInsets(top: 40, left: view.bounds.width * 0.4, bottom: 40, right: 40)
    }

    private func reloadSkin() {
        skinTask?.cancel()
        let pack = library.activePack
        let appearance: MapAppearance = traitCollection.userInterfaceStyle == .dark ? .night : .day
        let screenScale = traitCollection.displayScale
        skinTask = Task { [weak self, skinFactory] in
            do {
                let skin = try await skinFactory.makeSkin(pack: pack, appearance: appearance, screenScale: screenScale)
                guard !Task.isCancelled else { return }
                self?.apply(skin)
            } catch {
                self?.logger.error("Could not build CarPlay map skin: \(error.localizedDescription)")
            }
        }
    }

    private func apply(_ skin: MapSkin) {
        if let mapView {
            mapView.apply(skin)
            return
        }
        let newMapView = MapSkinView(skin: skin)
        newMapView.frame = view.bounds
        newMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(newMapView)
        mapView = newMapView
        newMapView.show(overlay)
        newMapView.setContentInset(contentInset(for: cameraMode))
        newMapView.setCameraMode(cameraMode, overviewPadding: overviewPadding)
    }
}
