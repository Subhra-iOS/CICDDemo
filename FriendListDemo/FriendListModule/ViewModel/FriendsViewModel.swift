//
//  FriendsViewModel.swift
//  FriendListDemo
//
//  Created by Subhra Roy on 13/12/21.
//

import Foundation

struct FriendsViewModel: ListProtocol {
    
    private let serviceManager: ServiceManager
    
    init(manager: ServiceManager) {
        self.serviceManager = manager
    }
    
    func load(list: @escaping (Swift.Result<[Friend], ServiceError<ErrorState>>)->()) {
        self.serviceManager.fetch { (result) in
            list(result)
        }
    }
}
