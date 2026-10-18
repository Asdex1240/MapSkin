import MapLibre
import MapStyle
import NavigationCore
import UIKit

public final class MapSkinView: UIView {
    private static let navigationCameraDuration: TimeInterval = 0.9
    private static let streetZoomLevel = 15.0

    public var onUserTrackingChange: ((Bool) -> Void)?

    private let mapView: MLNMapView
    private var skin: MapSkin
    private var overlay = RouteOverlay.empty
    private var cameraMode = MapCameraMode.followingUser
    private var overviewPadding = UIEdgeInsets.zero
    private var hasZoomedToUser = false

    public init(skin: MapSkin) {
        self.skin = skin
        mapView = MLNMapView(frame: .zero, styleJSON: skin.styleJSON)
        super.init(frame: .zero)
        embedMapView()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsUserHeadingIndicator = true
        mapView.userTrackingMode = .follow
        if let style = mapView.style {
            prepare(style)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    public func apply(_ newSkin: MapSkin) {
        guard newSkin.id != skin.id else { return }
        skin = newSkin
        mapView.styleJSON = newSkin.styleJSON
    }

    public func show(_ newOverlay: RouteOverlay) {
        guard newOverlay != overlay else { return }
        overlay = newOverlay
        if let style = mapView.style {
            RouteLayers.apply(overlay, palette: skin.palette, to: style)
        }
        if cameraMode == .routeOverview {
            showRouteOverview()
        }
    }

    public func setCameraMode(_ mode: MapCameraMode, overviewPadding padding: UIEdgeInsets) {
        let paddingChanged = padding != overviewPadding
        overviewPadding = padding
        guard mode != cameraMode || (mode == .routeOverview && paddingChanged) else { return }
        cameraMode = mode
        mapView.compassView.compassVisibility = mode == .navigation ? .hidden : .adaptive
        switch mode {
        case .followingUser:
            followUserLocation()
        case .routeOverview:
            showRouteOverview()
        case .navigation:
            mapView.setUserTrackingMode(.none, animated: false, completionHandler: nil)
        }
    }

    public func setBottomOrnamentInset(_ inset: CGFloat) {
        let margins = CGPoint(x: 8, y: inset + 8)
        guard mapView.logoViewMargins != margins else { return }
        mapView.logoViewMargins = margins
        mapView.attributionButtonMargins = margins
    }

    public func setContentInset(_ inset: UIEdgeInsets) {
        mapView.automaticallyAdjustsContentInset = false
        guard mapView.contentInset != inset else { return }
        mapView.setContentInset(inset, animated: true, completionHandler: nil)
    }

    public func zoom(by delta: Double) {
        mapView.setZoomLevel(mapView.zoomLevel + delta, animated: true)
    }

    public func pan(by offset: CGPoint) {
        let target = CGPoint(x: mapView.bounds.midX + offset.x, y: mapView.bounds.midY + offset.y)
        let coordinate = mapView.convert(target, toCoordinateFrom: mapView)
        mapView.setUserTrackingMode(.none, animated: false, completionHandler: nil)
        mapView.setCenter(coordinate, animated: true)
    }

    public func moveNavigationCamera(to sample: LocationSample) {
        guard cameraMode == .navigation else { return }
        let altitude = MLNAltitudeForZoomLevel(
            NavigationZoom.level(forSpeed: sample.speed),
            NavigationZoom.pitch,
            sample.coordinate.latitude,
            mapView.bounds.size
        )
        let camera = MLNMapCamera(
            lookingAtCenter: sample.coordinate.locationCoordinate,
            altitude: altitude,
            pitch: NavigationZoom.pitch,
            heading: sample.course ?? mapView.camera.heading
        )
        mapView.setCamera(
            camera,
            withDuration: Self.navigationCameraDuration,
            animationTimingFunction: CAMediaTimingFunction(name: .linear)
        )
    }

    public func followUserLocation() {
        cameraMode = .followingUser
        guard
            let coordinate = mapView.userLocation?.location?.coordinate,
            CLLocationCoordinate2DIsValid(coordinate)
        else {
            mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
            return
        }
        zoomToStreetLevel(at: coordinate, animated: true)
    }

    private func zoomToStreetLevel(at coordinate: CLLocationCoordinate2D, animated: Bool) {
        let zoomLevel = max(mapView.zoomLevel, Self.streetZoomLevel)
        let altitude = MLNAltitudeForZoomLevel(zoomLevel, 0, coordinate.latitude, mapView.bounds.size)
        let camera = MLNMapCamera(lookingAtCenter: coordinate, altitude: altitude, pitch: 0, heading: 0)
        mapView.setCamera(camera, withDuration: animated ? 0.6 : 0, animationTimingFunction: nil) { [weak self] in
            self?.mapView.setUserTrackingMode(.follow, animated: false, completionHandler: nil)
        }
    }

    private func showRouteOverview() {
        let coordinates = overlay.routes.flatMap(\.polyline).map(\.locationCoordinate)
        guard let bounds = Self.bounds(of: coordinates) else { return }
        mapView.setUserTrackingMode(.none, animated: false, completionHandler: nil)
        let camera = mapView.cameraThatFitsCoordinateBounds(bounds, edgePadding: overviewPadding)
        camera.pitch = 0
        camera.heading = 0
        mapView.setCamera(camera, animated: true)
    }

    private func embedMapView() {
        mapView.frame = bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(mapView)
    }

    private func prepare(_ style: MLNStyle) {
        for (name, texture) in skin.images {
            let image = UIImage(cgImage: texture.cgImage, scale: texture.scale, orientation: .up)
            style.setImage(image, forName: name)
        }
        RouteLayers.apply(overlay, palette: skin.palette, to: style)
    }

    private static func bounds(of coordinates: [CLLocationCoordinate2D]) -> MLNCoordinateBounds? {
        guard let first = coordinates.first else { return nil }
        return coordinates.dropFirst().reduce(MLNCoordinateBounds(sw: first, ne: first)) { bounds, coordinate in
            MLNCoordinateBounds(
                sw: CLLocationCoordinate2D(
                    latitude: min(bounds.sw.latitude, coordinate.latitude),
                    longitude: min(bounds.sw.longitude, coordinate.longitude)
                ),
                ne: CLLocationCoordinate2D(
                    latitude: max(bounds.ne.latitude, coordinate.latitude),
                    longitude: max(bounds.ne.longitude, coordinate.longitude)
                )
            )
        }
    }
}

extension MapSkinView: @preconcurrency MLNMapViewDelegate {
    public func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
        prepare(style)
    }

    public func mapView(_ mapView: MLNMapView, didUpdate userLocation: MLNUserLocation?) {
        guard
            !hasZoomedToUser,
            cameraMode == .followingUser,
            let coordinate = userLocation?.location?.coordinate,
            CLLocationCoordinate2DIsValid(coordinate)
        else { return }
        hasZoomedToUser = true
        zoomToStreetLevel(at: coordinate, animated: false)
    }

    public func mapView(_ mapView: MLNMapView, didChange mode: MLNUserTrackingMode, animated: Bool) {
        onUserTrackingChange?(mode != .none)
    }
}
