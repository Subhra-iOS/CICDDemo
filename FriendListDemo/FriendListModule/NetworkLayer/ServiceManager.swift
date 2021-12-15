//
//  ServiceManager.swift
//  FriendListDemo
//
//  Created by Subhra Roy on 13/12/21.
//

import Foundation

struct ServiceManager: ServiceProtocol {
    
    private let url: String
    
    init(url: String) {
        self.url = url
    }
    
    func fetch(list: @escaping (Result<[Friend], ServiceError<ErrorState>>) -> ()) {
        guard let serviceUrl: URL = URL(string: self.url) else{
            list(.failure(.failure(.nodata)))
            return
        }
        URLSession.shared.dataTask(with: serviceUrl) { (data, response, error) in
            guard let data = data, error == nil else {
                list(.failure(.failure(.nodata)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                list(.failure(.failure(.nodata)))
                return
            }
            
            switch httpResponse.statusCode{
                case 200:
                    if let parseJson: ParseJson = ParseJson(data: data),
                       let friends: [Friend] = try? parseJson.decodJson(){
                        list(.success(friends))
                    }else{
                        list(.failure(.failure(.invalid)))
                    }
                default:
                    list(.failure(.failure(.invalid)))
            }
        }.resume()
    }
}
