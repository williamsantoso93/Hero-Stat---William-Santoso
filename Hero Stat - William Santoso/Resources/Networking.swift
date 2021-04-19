//
//  Networking.swift
//  Hero Stat - William Santoso
//
//  Created by William Santoso on 18/04/21.
//

import Foundation

enum NetworkError: Error {
    case badUrl
    case decodingError
    case noData
}

class Networking {
    private init() { }
    
    static let shared = Networking()
    
    func getData<T:Codable>(from urlString: String, completion: @escaping (Result<T,NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            return completion(.failure(.badUrl))
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print(urlString)
                return completion(.failure(.noData))
            }
            
            guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
                print(urlString)
                print(String(data: data, encoding: .utf8) ?? "no data")
                return completion(.failure(.decodingError))
            }
            completion(.success(decoded))
        }.resume()
    }
}
