import PlaceSearch
import SwiftUI

struct SearchPanel: View {
    let model: HomeModel
    let onFocus: () -> Void

    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            searchField
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 8)
            List {
                content
            }
            .listStyle(.plain)
        }
        .onChange(of: isSearchFieldFocused) { _, isFocused in
            if isFocused { onFocus() }
        }
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(
                text: Binding(get: { model.searchText }, set: { model.updateSearchText($0) }),
                prompt: Text("search.placeholder", bundle: .module)
            ) {
                Text("search.placeholder", bundle: .module)
            }
            .focused($isSearchFieldFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()
            .onSubmit { Task { await model.submitSearch() } }
            if !model.searchText.isEmpty {
                Button {
                    model.updateSearchText("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(Text("search.clear", bundle: .module))
            }
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private var content: some View {
        if let message = model.searchErrorMessage {
            Text(message)
                .foregroundStyle(.secondary)
        }
        if model.searchText.isEmpty {
            FavoritesSection(model: model)
            RecentsSection(model: model)
        } else if !model.searchResults.isEmpty {
            Section {
                ForEach(model.searchResults) { place in
                    PlaceRow(model: model, place: place, symbolName: "mappin.circle.fill")
                }
            } header: {
                Text("search.results.title", bundle: .module)
            }
        } else {
            ForEach(model.placeSearch.suggestions) { suggestion in
                SuggestionRow(suggestion: suggestion) {
                    isSearchFieldFocused = false
                    Task { await model.choose(suggestion) }
                }
            }
        }
    }
}

private struct FavoritesSection: View {
    let model: HomeModel

    var body: some View {
        Section {
            if model.favorites.favorites.isEmpty {
                Text("search.favorites.empty", bundle: .module)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            ForEach(model.favorites.favorites) { favorite in
                Button {
                    Task { await model.planRoute(to: favorite.place) }
                } label: {
                    PlaceLabel(title: favorite.title, place: favorite.place, symbolName: favorite.symbolName)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        model.favorites.remove(favorite)
                    } label: {
                        Text("favorite.action.remove", bundle: .module)
                    }
                }
            }
        } header: {
            Text("search.favorites.title", bundle: .module)
        }
    }
}

private struct RecentsSection: View {
    let model: HomeModel

    var body: some View {
        if !model.recentPlaces.places.isEmpty {
            Section {
                ForEach(model.recentPlaces.places) { place in
                    PlaceRow(model: model, place: place, symbolName: "clock.arrow.circlepath")
                        .swipeActions {
                            Button(role: .destructive) {
                                model.recentPlaces.remove(place)
                            } label: {
                                Text("favorite.action.remove", bundle: .module)
                            }
                        }
                }
            } header: {
                HStack {
                    Text("search.recents.title", bundle: .module)
                    Spacer()
                    Button {
                        model.recentPlaces.removeAll()
                    } label: {
                        Text("search.recents.clear", bundle: .module)
                    }
                    .font(.footnote)
                }
            }
        }
    }
}
