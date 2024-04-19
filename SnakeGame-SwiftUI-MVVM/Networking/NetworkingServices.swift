//
//  NetworkingServices.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 24/02/2024.
//

import Foundation

protocol UsersDataProvider: AnyObject {
    func getImage(link: String?, completion: @escaping (Result<Data, Error>) -> Void)
    func getUserFromNet(completion: @escaping (Result<User, Error>) -> Void)
}

final class NetworkingServices: UsersDataProvider {
    
    static var shared = NetworkingServices()
    private let baseUrl = "https://randomuser.me/api/?inc=name,picture"
    private init () {}

    enum NetworkingErrors: Error {
        case wrongURL
        case wrongRequest
        case wrongDecoding
    }
    
    func getImage(link: String?, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let link = link, let url = URL(string: link) else {
            completion(.failure(NetworkingErrors.wrongURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NetworkingErrors.wrongDecoding))
            }
        }.resume()
    }
    
    func getUserFromNet(completion: @escaping (Result<User, Error>) -> Void) {
        guard let request = prepareRequest() else {
            completion(.failure(NetworkingErrors.wrongRequest))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkingErrors.wrongDecoding))
                return
            }
            
            do {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Received JSON data:", jsonString)
                }
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(Results.self, from: data)
                
                if let user = decodedData.results.first {
                    completion(.success(user))
                } else {
                    completion(.failure(NetworkingErrors.wrongDecoding))
                }
            } catch {
                print("Decoding error:", error)
                completion(.failure(NetworkingErrors.wrongDecoding))
            }
        }.resume()
    }
    
    private func prepareRequest() -> URLRequest? {
        guard let url = URL(string: baseUrl) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}
