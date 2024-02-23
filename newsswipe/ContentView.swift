//
//  ContentView.swift
//  newsswipe
//
//  Created by Ansh Mehta on 2/3/24.
//

import SwiftUI
struct NewsResponse: Decodable, Hashable {
    let articles: [NewsItem]
    let next_start_key: String?
}

struct NewsItem: Identifiable, Decodable, Hashable {
    let id: String
    let article_type: String
    let image_url: String
    let published_datetime: Int
    let region: String
    let summary: String
    let title: String
    let url: String
}

 var apiKey: String {
  get {
    // 1
    guard let filePath = Bundle.main.path(forResource: "secrets", ofType: "plist") else {
      fatalError("Couldn't find file 'TMDB-Info.plist'.")
    }
    // 2
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "api-key") as? String else {
      fatalError("Couldn't find key 'API_KEY' in 'TMDB-Info.plist'.")
    }
    return value
  }
}

class CallNewsApi: ObservableObject {
    @Published var newsItems = [NewsItem]()
    @Published var lastStartKey = String()
    @Published var  isLoading=false
    @Published var firstLoadScreen = true
    @Published var allCaughtUp = false
    @Published var showWebView = false
    func getNewsItems() ->Void {
        guard !isLoading else {return}
        isLoading = true
        let urlString = "https://trial.apim.trial-newsswipe.gravitee.xyz/news/get_top_news"
        var urlComponents = URLComponents(string: urlString)!
        
        var queryItems = [URLQueryItem(name: "user", value: UserDefaults.standard.string(forKey: UserIdentifierManager.shared.userIDKey))]
        if !lastStartKey.isEmpty {
            queryItems.append(URLQueryItem(name: "startKey", value: lastStartKey))
        }
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-Gravitee-Api-Key")
        
        URLSession.shared.dataTask(with:request) { (data, response, error) in
            guard error == nil else {print(error!.localizedDescription); return}
            guard let data = data else {print("empty data"); return}
            //print(data.base64EncodedString())
            do {
                 let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                 DispatchQueue.main.async {
                     self.newsItems.append(contentsOf: decoded.articles)
                     self.allCaughtUp = decoded.articles.isEmpty
                     self.lastStartKey = decoded.next_start_key ?? ""
                     self.firstLoadScreen = false
                 }
             } catch {
                 print("Decoding error: \(error.localizedDescription)")
             }
        }
        .resume()
        isLoading = false
    }
    
    func loadMore(currentItem newsItem: NewsItem){
        guard let index = newsItems.firstIndex(where: { $0.id == newsItem.id }) else {
                    return
                }
        if (self.newsItems.count-index <= 5){
                    print("hehe load more")
                    getNewsItems()
        }
    }

}



struct ContentView: View {
    
    @StateObject var newss = CallNewsApi()
    var body: some View {
        Group{
            if newss.firstLoadScreen == true  {
                LoadingView()
            }else{
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(newss.newsItems) { news in
                            
                            NewsItemView( viewModel: newss,news: news).onAppear(perform: {
                                newss.loadMore(currentItem: news )
                            }).id(news.id)
                            
                        }
                        if (newss.allCaughtUp == true){
                            Text("All Caught Up")
                        }
                    }
                }.scrollTargetBehavior(.paging)
                    .ignoresSafeArea()
                    
            }
        }.onAppear(perform: {
            UserIdentifierManager.shared.loadUser(ob:newss)
        })
    }
}


#Preview {
    ContentView()
}
