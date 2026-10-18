import MapLibre
import MapStyle
import UIKit

public final class MapSkinView: UIView {
    public var onUserTrackingChange: ((Bool) -> Void)?

    private let mapView: MLNMapView
    private var skin: MapSkin

    public init(skin: MapSkin) {
        self.skin = skin
        mapView = MLNMapView(frame: .zero, styleJSON: skin.styleJSON)
        super.init(frame: .zero)
        embedMapView()
        mapView.delegate = self
        followUserLocationOnLaunch()
        if let style = mapView.style {
            registerImages(in: style)
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

    public func followUserLocation() {
        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
    }

    private func embedMapView() {
        mapView.frame = bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(mapView)
    }

    private func followUserLocationOnLaunch() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }

    private func registerImages(in style: MLNStyle) {
        for (name, texture) in skin.images {
            let image = UIImage(cgImage: texture.cgImage, scale: texture.scale, orientation: .up)
            style.setImage(image, forName: name)
        }
    }
}

extension MapSkinView: @preconcurrency MLNMapViewDelegate {
    public func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
        registerImages(in: style)
    }

    public func mapView(_ mapView: MLNMapView, didChange mode: MLNUserTrackingMode, animated: Bool) {
        onUserTrackingChange?(mode != .none)
    }
}
