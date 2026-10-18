import MapRendering
import MapStyle
import NavigationCore
import SwiftUI

struct MapSkinRepresentable: UIViewRepresentable {
    let skin: MapSkin
    let overlay: RouteOverlay
    let cameraMode: MapCameraMode
    let overviewPadding: UIEdgeInsets
    let bottomOrnamentInset: CGFloat
    let navigationSample: LocationSample?
    let recenterRequest: Int
    @Binding var isFollowingUser: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(handledRecenterRequest: recenterRequest)
    }

    func makeUIView(context: Context) -> MapSkinView {
        let view = MapSkinView(skin: skin)
        view.onUserTrackingChange = { isFollowing in
            isFollowingUser = isFollowing
        }
        return view
    }

    func updateUIView(_ uiView: MapSkinView, context: Context) {
        uiView.apply(skin)
        uiView.setBottomOrnamentInset(bottomOrnamentInset)
        uiView.show(overlay)
        uiView.setCameraMode(cameraMode, overviewPadding: overviewPadding)
        if let navigationSample, navigationSample != context.coordinator.handledNavigationSample {
            context.coordinator.handledNavigationSample = navigationSample
            uiView.moveNavigationCamera(to: navigationSample)
        }
        if context.coordinator.handledRecenterRequest != recenterRequest {
            context.coordinator.handledRecenterRequest = recenterRequest
            uiView.followUserLocation()
        }
    }

    final class Coordinator {
        var handledRecenterRequest: Int
        var handledNavigationSample: LocationSample?

        init(handledRecenterRequest: Int) {
            self.handledRecenterRequest = handledRecenterRequest
        }
    }
}
