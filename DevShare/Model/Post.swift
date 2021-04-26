//
//  Post.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import Firebase

struct Post {
    var caption: String
    var likes: Int
    var reports: Int
    
    let imageUrl: String
    let ownerUid: String
    let timestamp: Timestamp
    let postID: String
    
    let ownerImageUrl: String
    let ownerUsername: String
    
    var didLike = false
    
    init(postID: String, dictionary: [String: Any]) {
        self.postID = postID
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.reports = dictionary["reports"] as? Int ?? 0
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.ownerImageUrl = dictionary["ownerImageUrl"] as? String ?? ""
        self.ownerUsername = dictionary["ownerUsername"] as? String ?? ""
    }
}
