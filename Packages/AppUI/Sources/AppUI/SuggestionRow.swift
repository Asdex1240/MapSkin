import PlaceSearch
import SwiftUI

struct SuggestionRow: View {
    let suggestion: SearchSuggestion
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: suggestion.title)
                        .foregroundStyle(.primary)
                    if !suggestion.subtitle.isEmpty {
                        Text(verbatim: suggestion.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}
