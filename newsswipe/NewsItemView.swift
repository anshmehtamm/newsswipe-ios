//
//  NewsItemView.swift
//  newsswipe
//
//  Created by Ansh Mehta on 2/3/24.
//

import SwiftUI
import WebKit

var apiKeyy: String {
 get {
   // 1
   guard let filePath = Bundle.main.path(forResource: "secrets", ofType: "plist") else {
     fatalError("Couldn't find file 'TMDB-Info.plist'.")
   }
   // 2
   let plist = NSDictionary(contentsOfFile: filePath)
   guard let value = plist?.object(forKey: "api-key-view") as? String else {
     fatalError("Couldn't find key 'API_KEY' in 'TMDB-Info.plist'.")
   }
   return value
 }
}


struct WebView: UIViewRepresentable {
    
    
    
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {

        let webView = WKWebView()
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedString) {
                    let request = URLRequest(url: url)
                    webView.load(request)
                }
                return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the view if needed.
    }
}

func formatDate(fromUnixTimestamp unixTimestamp: Int) -> String {
    if let unixTimestampDouble = Double(String(unixTimestamp)) {
        let date = Date(timeIntervalSince1970: unixTimestampDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMMM d, yyyy HH:mm"
        return dateFormatter.string(from: date)
    } else {
        return "N/A"
    }
}


func callUpdateViewedAPI(articleId: String) {
    
    
    let urlString = "http://54.242.117.139/news/viewed"
    guard let url = URL(string: urlString) else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    //print(UserIdentifierManager.shared.user)
    let body: [String: Any] = ["user": UserDefaults.standard.string(forKey: UserIdentifierManager.shared.userIDKey), "article_id": articleId]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    
    
    URLSession.shared.dataTask(with: request) { data, response, error in
           guard let data = data, error == nil else {
               print(error?.localizedDescription ?? "No data")
               return
           }
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            // Successfully sent the userID to the server
            print("Successfully sent view to server")
        } else {
            print(data.base64EncodedString())
            // Server responded with an error
            print("Failed to send view to server")
        }
       }.resume()
}

struct NewsItemView: View {
    @ObservedObject var viewModel: CallNewsApi
    let news: NewsItem
    let shouldShowHomeView: Bool
    @State private var viewTimer: Timer?
    // Add a state to track if the news item is marked as favorite
    @State private var isFavorite: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: news.image_url)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width, height: 250)
            .clipped()
            
            HStack {
                Text(news.title)
                    .font(.headline).foregroundColor(Color.black)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                Spacer()
                
                // Button to toggle the favorite status
                Button(action: {
                    // Toggle the favorite status
                    isFavorite.toggle()
                    FavoritesManager.shared.toggleFavorite(newsId: news.id)
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .gray)
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                }
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                Text(news.summary.replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil)).foregroundColor(Color.black)
                    .font(.body).padding(.top, 5)
                    .padding([.horizontal, .bottom])
            }
            // Here's the formatted date text
            Text(formatDate(fromUnixTimestamp: news.published_datetime))
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom)
            HStack {
                Button(action: {
                    viewModel.showHomeView = true
                }) {
                    HStack {
                        Image(systemName: "house")
                    }
                }
                .frame(maxWidth: 30)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()

                Button(action: {
                    viewModel.showWebView = true
                }) {
                    HStack {
                        Image(systemName: "link.circle.fill")
                        Text("Read More")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .sheet(isPresented: $viewModel.showWebView, onDismiss: {}, content: {
                    WebView(urlString: news.url)
                })
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            // Start a timer when the card appears
            viewTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                callUpdateViewedAPI(articleId: news.id)
                isFavorite = FavoritesManager.shared.isFavorite(newsId: news.id)
            }
        }
        .onDisappear {
            // Invalidate the timer if the view disappears to prevent the API call
            viewTimer?.invalidate()
        }
        // .padding(.horizontal) // This padding was removed because it's already full screen
    }
}
#Preview {
//    NewsItemView(index:1, dataa: new NewsItem(article_id: "a", article_type: "a", image_url: "a", published_datetime: "a", region: "a", summary: "a", title: "a", url: "a"))
    NewsItemView(viewModel: CallNewsApi() ,news: NewsItem(id: "", article_type: "", image_url: "https://www.nasaspaceflight.com/wp-content/uploads/2024/02/NSF-2024-02-05-21-42-58-718-scaled.jpg", published_datetime: 1707187541, region: "us", summary: "Will the Nuggets do anything at the NBA trade deadline to improve at the guard or center spots?\nHe would be a solid fit with Milwaukee, but the Raptors are seeking first-round draft and/or young players in a deal for Brown. The Bucks don2019t have those assets, with future first-round picks in 2024, 2025, 2026, 2027, 2028 and 2029 tied up in pick swaps or already traded.\nThe deal also signals Charlotte's plans to amass draft picks. Pistons get veterans Danilo Gallinari, Mike Muscala from WizardsJan. 14: The Detroit Pistons acquired Danilo Gallinari and Mike Muscala from the Washington Wizards for Marvin Bagley, Isaiah Livers and two second-round draft picks.", title: "Falcon 9 set to launch PACE science satellite for NASA", url: "https://news.google.com/rss/articles/CBMiNGh0dHBzOi8vd3d3Lm5hc2FzcGFjZWZsaWdodC5jb20vMjAyNC8wMi9wYWNlLWxhdW5jaC_SAQA?oc=5&hl=en-US&gl=US&ceid=US:en"), shouldShowHomeView: false)
}
