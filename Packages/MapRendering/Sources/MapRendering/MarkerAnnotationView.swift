import MapLibre
import UIKit

final class MarkerAnnotationView: MLNUserLocationAnnotationView {
    private static let minimumSpeedForCourse = 0.5

    private let imageView = UIImageView()
    private var lastCourse = 0.0

    init(image: UIImage, usesNearestFiltering: Bool) {
        super.init(frame: CGRect(origin: .zero, size: image.size))
        imageView.image = image
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if usesNearestFiltering {
            imageView.layer.magnificationFilter = .nearest
            imageView.layer.minificationFilter = .nearest
        }
        addSubview(imageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func update() {
        if let location = userLocation?.location,
           location.course >= 0,
           location.speed >= Self.minimumSpeedForCourse {
            lastCourse = location.course
        }
        let mapDirection = mapView?.direction ?? 0
        let angle = (lastCourse - mapDirection) * .pi / 180
        imageView.transform = CGAffineTransform(rotationAngle: angle)
    }
}
