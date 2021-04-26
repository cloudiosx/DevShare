//
//  FeedCellViewModel.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

struct FeedCellViewModel {
    
    private let user: User
    
    var followButtonText: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        return user.isCurrentUser ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return user.isCurrentUser ? .black : .white
    }
    
    init(user: User) {
        self.user = user
    }
    
}
