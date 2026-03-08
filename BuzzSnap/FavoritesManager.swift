import Foundation

final class FavoritesManager: ObservableObject {
    @Published private(set) var favoriteModes: Set<String> = []

    private let defaultsKey = "favoriteBuzzModes"

    init() {
        loadFavorites()
    }

    func isFavorite(_ mode: BuzzMode) -> Bool {
        favoriteModes.contains(mode.rawValue)
    }

    func toggle(_ mode: BuzzMode) {
        if favoriteModes.contains(mode.rawValue) {
            favoriteModes.remove(mode.rawValue)
        } else {
            favoriteModes.insert(mode.rawValue)
        }
        saveFavorites()
    }

    private func loadFavorites() {
        let values = UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
        favoriteModes = Set(values)
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteModes), forKey: defaultsKey)
    }
}
