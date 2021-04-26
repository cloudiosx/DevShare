//
//  UserCellViewModel.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import Foundation

struct UserCellViewModel {
    private let user: User
    
    var username: String {
        return user.username
    }
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    init(user: User) {
        self.user = user
    }
}
