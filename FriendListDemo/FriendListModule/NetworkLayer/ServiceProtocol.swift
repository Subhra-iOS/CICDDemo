//
//  ServiceProtocol.swift
//  FriendListDemo
//
//  Created by Subhra Roy on 13/12/21.
//

import Foundation

enum ErrorState: Int{
    case nodata
    case invalid
    case unknown
}

enum ServiceError<ErrorState>: Error{
    case success
    case failure(ErrorState)
}

protocol ServiceProtocol {
    func fetch(list: @escaping (Swift.Result<[Friend], ServiceError<ErrorState>>) ->())
}


struct ParseJson: DecodableProtocol{
    private let data: Data
    
    init?(data: Data?) {
        guard let response = data else {
            return nil
        }
        self.data = response
    }
    
    func decodJson() throws -> [Friend]? {
        do{
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .useDefaultKeys
            let response = try jsonDecoder.decode([Friend].self, from: self.data)
            return response
        }catch {
            throw JsonDecodeError.parseError
        }
    }
}
