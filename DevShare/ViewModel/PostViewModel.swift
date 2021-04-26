//
//  PostViewModel.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

struct PostViewModel {
    var post: Post
    
    var imageUrl: URL? {
        return URL(string: post.imageUrl)
    }
    
    var userProfileImageUrl: URL? {
        return URL(string: post.ownerImageUrl)
    }
    
    var username: String {
        return post.ownerUsername
    }
    
    var likes: Int {
        return post.likes
    }
    
    var caption: String {
        return post.caption
    }
    
    var likeButtonTintColor: UIColor {
        return post.didLike ? .red : .black
    }
    
    var likeButtonImage: UIImage {
        return post.didLike ? #imageLiteral(resourceName: "heart copy") : #imageLiteral(resourceName: "heart")
    }
    
    var likesLabelText: String {
        if post.likes != 1 {
            return "\(post.likes) likes"
        } else {
            return "\(post.likes) like"
        }
    }
    
    init(post: Post) {
        self.post = post
    }
}
