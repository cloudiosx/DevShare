//
//  ProfileHeaderViewModel.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

struct ProfileHeaderViewModel {
    
    let user: User
    
    var username: String {
        return user.username
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var numberOfFollowers: NSAttributedString {
        return attributedUserStats(number: user.userStats?.follower ?? 0, label: "followers")
    }
    
    var numberOfFollowing: NSAttributedString {
        return attributedUserStats(number: user.userStats?.following ?? 0, label: "following")
    }
    
    var numberOfPosts: NSAttributedString {
        return attributedUserStats(number: user.userStats?.posts ?? 0, label: "posts")
    }
    
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
    
    func attributedUserStats(number: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(number)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: label, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
    
}
