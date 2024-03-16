//
//  FavoritesManager.swift
//  newsswipe
//
//  Created by Ansh Mehta on 3/9/24.
//

import Foundation


class FavoritesManager{
    private let favoritesKey = "Favorites_Key"
    static let shared = FavoritesManager()
    
    func saveFavorite(newsId: String) {
        var fav = getFavorites()
        if !fav.contains(newsId) {
            fav.append(newsId)
            UserDefaults.standard.set(fav, forKey: favoritesKey)
        }
    }
    
    func removeFavorite(newsId: String) {
            var favorites = getFavorites()
            if let index = favorites.firstIndex(of: newsId) {
                favorites.remove(at: index)
                UserDefaults.standard.set(favorites, forKey: favoritesKey)
            }
    }
    
    func getFavorites() -> [String] {
        let favs =  UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        return favs
    }

    func isFavorite(newsId: String) -> Bool {
        return getFavorites().contains(newsId)
    }
    
    func toggleFavorite(newsId: String) {
        if isFavorite(newsId: newsId) {
            removeFavorite(newsId: newsId)
        } else {
            saveFavorite(newsId: newsId)
        }
    }
        
}
