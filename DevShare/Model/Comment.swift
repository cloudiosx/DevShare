//
//  Comment.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import Firebase

struct Comment {
    let uid: String
    let username: String
    let profileImageUrl: String
    let timestamp: Timestamp
    let comment: String
    var reports: Int
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.comment = dictionary["comment"] as? String ?? ""
        self.reports = dictionary["reports"] as? Int ?? 0
    }
}
