//
//  ProfileHeaderViewModel.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

struct ProfileHeaderViewModel {
    
    private var user: User
    
    init(user: User) {
        self.user = user
    }
    
    func getUser() -> User {
        return self.user
    }
    
    mutating func setUser(value: User) {
        self.user = value
    }
    
    func isCurrentUser() -> Bool {
        return user.isCurrentUser
    }
    
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
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        return user.isFollowed ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return user.isFollowed ? .black : .white
    }
    
    func attributedUserStats(number: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(number)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: label, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
    
}
