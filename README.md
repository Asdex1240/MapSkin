# MapSkin

Turn-by-turn navigation for iPhone and Apple CarPlay with fully customizable map textures.
Every kind of terrain (grass, forest, water, sand, urban areas, buildings…) is drawn with a repeating texture
from the active texture pack, in any style, with day and night variants. Roads and the route are always drawn
in flat, high-contrast colors so the map stays readable while driving.

MapSkin is free, has no ads or accounts, and is open source under the MIT License.

## Requirements

- Xcode 26 or later
- iOS 17 or later

## Building

1. Clone the repository.
2. Copy `Config/Local.xcconfig.example` to `Config/Local.xcconfig` and set your own `DEVELOPMENT_TEAM` and
   `PRODUCT_BUNDLE_IDENTIFIER`. This file is ignored by git.
3. Open `MapSkin.xcodeproj` and run the `MapSkin` scheme on an iPhone simulator.

Without `Local.xcconfig` the project still builds for the simulator using placeholder values.

Run the tests with ⌘U in Xcode, or:

```sh
xcodebuild test -project MapSkin.xcodeproj -scheme MapSkin -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Project structure

The app target only composes the app. Features live in local Swift packages under `Packages/`:

| Package | Responsibility |
|---|---|
| `TexturePacks` | `.mapskin` format, texture loading and filtering, night variants, bundled packs |
| `MapStyle` | Style generation (day/night), palettes, color contrast rules |
| `MapRendering` | `MapSkinView`, the MapLibre map shared by iPhone and CarPlay |
| `AppUI` | SwiftUI screens for iPhone |

More packages are added as the features that need them are built.

## Map data

Map tiles and fonts come from [OpenFreeMap](https://openfreemap.org), a free service. Their URLs are set in
`Config/Shared.xcconfig`. If you publish your own build with many users, consider hosting your own tiles or using
another provider.

## Credits

- Map data © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright)
- Tiles by [OpenFreeMap](https://openfreemap.org)
- Rendering by [MapLibre Native](https://github.com/maplibre/maplibre-native)

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

Code: [MIT](LICENSE). Bundled texture packs: [CC0 1.0](Packages/TexturePacks/Sources/TexturePacks/BundledPacks/LICENSE).
# MapSkin
