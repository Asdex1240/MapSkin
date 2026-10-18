import PlaceSearch
import SwiftUI

extension Favorite {
    var title: Text {
        switch role {
        case .home: Text("favorite.home", bundle: .module)
        case .work: Text("favorite.work", bundle: .module)
        case .custom: Text(verbatim: place.name)
        }
    }

    var symbolName: String {
        switch role {
        case .home: "house.fill"
        case .work: "briefcase.fill"
        case .custom: "star.fill"
        }
    }
}
