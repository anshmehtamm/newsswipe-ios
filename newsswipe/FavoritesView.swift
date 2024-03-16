//
//  FavoritesView.swift
//  newsswipe
//
//  Created by Ansh Mehta on 3/9/24.
//

import SwiftUI

struct NewsByIdResponse:  Decodable, Hashable {
    let articles: [NewsItem]
}

class FavoritesViewApi: ObservableObject {
    @Published var favItems = [NewsItem]()
    @Published var isLoadingFavorites = false
    
    func getFavoritesItems() -> Void {
        guard !isLoadingFavorites else {return}
        isLoadingFavorites = true
        let urlString = "http://54.242.117.139/news/byIds"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //print(UserIdentifierManager.shared.user)
        
        let body: [String: Any] = ["newsIds":  FavoritesManager.shared.getFavorites()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        URLSession.shared.dataTask(with: request) { data, response, error in
           guard let data = data, error == nil else {
               print(error?.localizedDescription ?? "No data")
               return
           }
            do {
                 let decoded = try JSONDecoder().decode(NewsByIdResponse.self, from: data)
                 DispatchQueue.main.async {
                     self.favItems.append(contentsOf: decoded.articles)
                     self.isLoadingFavorites = false
                 }
             } catch {
                 print("Decoding error: \(error.localizedDescription)")
             }
            // decode the result and set.
        }.resume()
        self.isLoadingFavorites = false
    }
}
struct FavoritesView: View {
    @StateObject var favNewsApi = FavoritesViewApi()
    @ObservedObject var viewModel: CallNewsApi
    
    var body: some View {
        Group{
            if favNewsApi.isLoadingFavorites {
                Text("Loading Favorites")
            } else {
                NavigationView {
                    List {
                        ForEach(favNewsApi.favItems) { newsItem in
                            NavigationLink(destination: NewsItemView(viewModel: viewModel ,news: newsItem, shouldShowHomeView: false)) {
                                HStack {
                                    AsyncImage(url: URL(string: newsItem.image_url)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                    
                                    Text(newsItem.title)
                                        .lineLimit(3)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    // Implement favorite removal logic here
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    }
                    .navigationTitle("Favorites")
                }
            }
        }.onAppear {
            favNewsApi.getFavoritesItems()
        }
        
    }
}

