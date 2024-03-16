//
//  UserIdentifierManager.swift
//  newsswipe
//
//  Created by Ansh Mehta on 2/18/24.
//

import Foundation

class UserIdentifierManager {
    private let userDefaults = UserDefaults.standard
    let userIDKey = "ifriniqueUserIDDAAAAAAAA"
    var user = ""
    
    var apiKeyyy: String {
     get {
       // 1
       guard let filePath = Bundle.main.path(forResource: "secrets", ofType: "plist") else {
         fatalError("Couldn't find file 'TMDB-Info.plist'.")
       }
       // 2
       let plist = NSDictionary(contentsOfFile: filePath)
       guard let value = plist?.object(forKey: "api-key-create") as? String else {
         fatalError("Couldn't find key 'API_KEY' in 'TMDB-Info.plist'.")
       }
       return value
     }
   }
    
    // Singleton instance
    static let shared = UserIdentifierManager()
    
    private init() {}
    
    func loadUser(ob:CallNewsApi) {
        // Check if we already have a saved user ID
        if let userID = userDefaults.string(forKey: userIDKey) {
          
            user = userID
            ob.getNewsItems()
            
        } else {
            sendUserIDToServer(obb:ob)
        }
    }
    
     func sendUserIDToServer(obb:CallNewsApi) {

             let urlString = "http://54.242.117.139/news/create"
             guard let url = URL(string: urlString) else { return }
             
             var request = URLRequest(url: url)
             request.httpMethod = "POST"
             request.addValue("application/json", forHTTPHeaderField: "Content-Type")
             let body: [String: Any] = ["user":  String(UUID().uuidString.prefix(15))]
             request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
             URLSession.shared.dataTask(with: request) { data, response, error in
                 guard let data = data, error == nil else {
                     // Handle the error here
                     print(error?.localizedDescription ?? "Unknown error")
                     return
                 }
                 
                 // Here, you can handle the server's response
                 if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                     // Successfully sent the userID to the server
                    
                     
                     let responseString = String(data: data, encoding: .utf8)
                     let trimmedResponseString = responseString?.trimmingCharacters(in: CharacterSet(charactersIn: "\"\n"))
                     UserDefaults.standard.set(trimmedResponseString, forKey: "ifriniqueUserIDDAAAAAAAA")
                    
                     self.user = trimmedResponseString ?? " "
                     DispatchQueue.main.async {
                                
                         obb.getNewsItems()
                                 }
                 } else {
                     // Server responded with an error
                     print("Failed to send userID to server")
                 }
    
             }.resume()
             
         
       }
}
