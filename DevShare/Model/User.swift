//
//  User.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import Firebase

struct User {
    let email: String
    let fullname: String
    let profileImageUrl: String
    let uid: String
    let username: String
    
    var blockedUsers: [User]?
    
    var userStats: UserStats?
    
    var isFollowed = false
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
    }
}

struct UserStats {
    let follower: Int
    let following: Int
    let posts: Int
}
