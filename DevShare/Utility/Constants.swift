//
//  Constants.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import Firebase

// MARK: - Collections

let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("userWhoFollowed")
let COLLECTION_FOLLOWED = Firestore.firestore().collection("userWhoGotFollowed")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
