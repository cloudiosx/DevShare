//
//  PostService.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit
import Firebase

struct PostService {
    static func uploadPost(_ caption: String, _ post: UIImage, _ user: User, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: post) { (imageUrl) in
            let data: [String: Any] = ["caption": caption,
                                       "ownerUid": currentUid,
                                       "likes": 0,
                                       "timestamp": Timestamp(date: Date()),
                                       "imageUrl": imageUrl,
                                       "ownerImageUrl": user.profileImageUrl,
                                       "ownerUsername": user.username,
                                       "reports": 0]
            
            COLLECTION_POSTS.addDocument(data: data, completion: completion)
        }
    }
    
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an error getting the documents for the posts \(e.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else { return }
            let posts = documents.map({ Post(postID: $0.documentID, dictionary: $0.data()) })
            completion(posts)
        }
    }
    
    static func fetchProfilePosts(forUser uid: String, completion: @escaping([Post]) -> Void) {
        COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { (querySnapshot, error) in
            guard let safelyUnwrappedQuerySnapshot = querySnapshot else { return }
            
            if let e = error {
                print("There was an error fetching the profile posts \(e.localizedDescription)")
                return
            }
            var posts = safelyUnwrappedQuerySnapshot.documents.map({ Post(postID: $0.documentID, dictionary: $0.data()) })
            posts.sort { (post1, post2) -> Bool in
                return post1.timestamp.seconds > post2.timestamp.seconds
            }
            completion(posts)
        }
    }
    
    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_POSTS.document(post.postID).updateData(["likes": post.likes + 1])
        COLLECTION_POSTS.document(post.postID).collection("post-likes").document(currentUid).setData([:]) { (_) in
            COLLECTION_USERS.document(currentUid).collection("user-likes").document(post.postID).setData([:], completion: completion)
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard post.likes > 0 else { return }
        COLLECTION_POSTS.document(post.postID).updateData(["likes": post.likes - 1])
        COLLECTION_POSTS.document(post.postID).collection("post-likes").document(currentUid).delete { (_) in
            COLLECTION_USERS.document(currentUid).collection("user-likes").document(post.postID).delete(completion: completion)
        }
    }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("user-likes").document(post.postID).getDocument { (snapshot, error) in
            if let e = error {
                print("There was an error fetching the profile posts \(e.localizedDescription)")
                return
            }
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }
    
    static func reportPost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_POSTS.document(post.postID).updateData(["reports": post.reports + 1])
        COLLECTION_POSTS.document(post.postID).collection("post-reports").document(currentUid).setData([:]) { (_) in
            COLLECTION_USERS.document(currentUid).collection("user-reports").document(post.postID).setData([:], completion: completion)
        }
    }
    
    static func checkIfPostIsCurrentuser(post: Post, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_POSTS.whereField("ownerUid", isEqualTo: currentUid).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            let documentID = documents.map({ $0.documentID })
            print(documentID)
            
            COLLECTION_POSTS.document(post.postID).collection("post-reports").getDocuments { (querySnapshot, error) in
                if documentID.contains(post.postID) {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    static func fetchUnblockedUserPosts(completion: @escaping([Post]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("blocked").getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an error getting the documents for the blocked users \(e.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else { return }
            let documentID = documents.map({ $0.documentID })
            print("blocked documentID is \(documentID)")
            
            COLLECTION_POSTS.whereField("ownerUid", notIn: documentID).getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an error getting the documents for the posts \(e.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                let posts = documents.map({ Post(postID: $0.documentID, dictionary: $0.data()) })
                print(posts)
                completion(posts)
            }
        }
    }
    
    static func fetchGotBlockedByPosts(completion: @escaping([Post]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("gotBlockedBy").getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an error getting the documents for the blocked users \(e.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else { return }
            let documentID = documents.map({ $0.documentID })
            print("gotBlockedBy documentID is \(documentID)")
            
            COLLECTION_POSTS.whereField("ownerUid", notIn: documentID).getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an error getting the documents for the posts \(e.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                let posts = documents.map({ Post(postID: $0.documentID, dictionary: $0.data()) })
                print(posts)
                completion(posts)
            }
        }
    }
    
    static func checkIfUserHasBlockedAnyone(completion: @escaping(Int) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("blocked").getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an error getting the documents for the blocked users \(e.localizedDescription)")
                return
            }
            guard let blockedCount = querySnapshot?.count else { return }
            print("blockedCount is \(blockedCount)")
            
            COLLECTION_USERS.document(currentUid).collection("gotBlockedBy").getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an error getting the documents for the blocked users \(e.localizedDescription)")
                    return
                }
                
                guard let gotBlockedByCount = querySnapshot?.count else { return }
                print("gotBlockedByCount is \(gotBlockedByCount)")
                
                if blockedCount > 0 && gotBlockedByCount == 0 {
                    completion(1)
                } else if blockedCount == 0 && gotBlockedByCount > 0 {
                    completion(2)
                } else if blockedCount > 0 && gotBlockedByCount > 0 {
                    completion(3)
                } else if blockedCount == 0 && gotBlockedByCount == 0 {
                    completion(4)
                } else {
                    completion(5)
                }
            }
        }
    }
}
