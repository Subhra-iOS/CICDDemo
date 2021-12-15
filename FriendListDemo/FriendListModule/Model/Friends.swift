//
//  Friends.swift
//  FriendListDemo
//
//  Created by Subhra Roy on 13/12/21.
//

import Foundation

enum JsonDecodeError: Error{
    case none
    case parseError
}

protocol DecodableProtocol {
    func decodJson() throws -> [Friend]?
}

struct Friend: Codable {
    let id: Double
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
}


