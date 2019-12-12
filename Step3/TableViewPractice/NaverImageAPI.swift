//
//  NaverImageAPI.swift
//  TableViewPractice
//
//  Created by admin on 2019/12/08.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import Foundation

class NaverImageAPI {
    static let baseURL = "https://openapi.naver.com/v1/search/image"
    
    static let defaultSession = URLSession(configuration: .default)
    static var dataTask: URLSessionDataTask?
    
    static func request(query: String, display: Int, start: Int, sort: String, filter: String, completionHandler: @escaping (Result<NaverImagResult, NaverError>) -> Void) {
        
        NaverImageAPI.dataTask?.cancel()
        
        let urlString = NaverImageAPI.baseURL //+ "?" + "query=" + "\(query)"
        print(urlString)
        
        guard var url = URLComponents(string: urlString) else {
            return
        }
        
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "query", value: query))
        queryItems.append(URLQueryItem(name: "display", value: "\(display)"))
        queryItems.append(URLQueryItem(name: "start", value: "\(start)"))
        url.queryItems = queryItems
        
        var request = URLRequest(url: url.url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(SecretKey.clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(SecretKey.secretKey, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        request.httpMethod = "GET"
        
        dataTask = NaverImageAPI.defaultSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {return}
            
            let decoder = JSONDecoder()
            do {
                let parsed = try decoder.decode(NaverImagResult.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(.success(parsed))
                }
            } catch {
                completionHandler(.failure(.JsonParksingError))
            }
        }
        dataTask?.resume()
    }
}

enum NaverError: Error {
    case JsonParksingError
}
