//
//  PostController.swift
//  WhyiOS
//
//  Created by Kaden Staker on 10/17/18.
//  Copyright © 2018 Kaden Staker. All rights reserved.
//

import Foundation

class PostController {
    
    var posts: [Post] = []
    
    static let baseURL = URL(string: "https://whydidyouchooseios.firebaseio.com/reasons")
    
    static func getPosts(completion: @escaping ([Post]?) -> Void) {
        
        guard let url = baseURL else { fatalError("Bad base url.") }
        let builtURL = url.appendingPathExtension("json")
        print(builtURL)
        
        var request = URLRequest(url: builtURL)
        request.httpMethod = "GET"
        request.httpBody = nil
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error getting post objects: \(error) \(error.localizedDescription)")
                completion(nil); return
            }
            guard let data = data else { completion(nil); return }
            do {
                let decoder = JSONDecoder()
                let postDictionary = try decoder.decode([String: Post].self, from: data)
                let posts = postDictionary.compactMap{ $1 }
                completion(posts)
                return
            } catch let error {
                print("Error decoding post objects: \(error) \(error.localizedDescription)")
            }
            }.resume()
    }
    
    static func postReason(name: String, cohort: String, reason: String, completion: @escaping ([Post]?) -> Void) {
        guard let url = baseURL else { fatalError("Bad base url.") }
        let builtURL = url.appendingPathExtension("json")
        print(builtURL)
        
        let post = Post(name: name, cohort: cohort, reason: reason)
        var postData = Data()
        
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(post)
        } catch let error {
            print("Error encoding post object \(error) \(error.localizedDescription)")
            completion(nil); return
        }
        
        var request = URLRequest(url: builtURL)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error posting post object: \(error) \(error.localizedDescription)")
                completion(nil); return
            }
            // Refreshing list of posts after we tap post
            getPosts(completion: { (posts) in
                completion(posts); return
            })
            }.resume()
    }
}
