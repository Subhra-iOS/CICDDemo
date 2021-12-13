//
//  ListProtocol.swift
//  FriendListDemo
//
//  Created by Subhra Roy on 13/12/21.
//

import Foundation

protocol ListProtocol {
    func load(list: @escaping (Swift.Result<[Friend], ServiceError<ErrorState>>) -> ())
}
