import MapLibre
import UIKit

public final class MapSkinView: UIView {
    private let mapView: MLNMapView

    public init(styleURL: URL) {
        mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        super.init(frame: .zero)
        embedMapView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    private func embedMapView() {
        mapView.frame = bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(mapView)
    }
}
