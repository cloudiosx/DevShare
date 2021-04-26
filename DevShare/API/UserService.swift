//
//  UserService.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import Firebase

typealias FirestoreCompletion = (Error?) -> Void

struct UserService {
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        //        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).getDocument { (documentSnapshot, error) in
            if let e = error {
                print("There was an error getting the document of the current user \(e.localizedDescription)")
                return
            }
            guard let data = documentSnapshot?.data() else { return }
            let user = User(dictionary: data)
            completion(user)
        }
    }
    
    static func fetchAllUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an error getting all documents from the users collection \(e.localizedDescription)")
                return
            }
            guard let safelyUnwrappedQuerySnapshot = querySnapshot else { return }
            let users = safelyUnwrappedQuerySnapshot.documents.map({ User(dictionary: $0.data() )})
            completion(users)
        }
    }
    
    static func fetchAllBlockedUsers(completion: @escaping([User]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("blocked").getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an error getting the documents for the blocked users \(e.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else { return }
            let documentID = documents.map({ $0.documentID })
            
            COLLECTION_USERS.whereField("uid", notIn: documentID).getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an error getting the documents for the users \(e.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                let users = documents.map({ User(dictionary: $0.data()) })
                completion(users)
            }
        }
    }
    
    static func fetchAllGotBlockedByUsers(completion: @escaping([User]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("gotBlockedBy").getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an error getting the documents for the blocked users \(e.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else { return }
            let documentID = documents.map({ $0.documentID })
            
            COLLECTION_USERS.whereField("uid", notIn: documentID).getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an error getting the documents for the users \(e.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                let users = documents.map({ User(dictionary: $0.data()) })
                completion(users)
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
    
    static func follow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(currentUid).collection("following").document(uid).setData([:]) { (error) in
            if let e = error {
                print("There was an error setting the data for the follow API \(e.localizedDescription)")
                return
            }
            COLLECTION_FOLLOWED.document(uid).collection("followers").document(currentUid).setData([:], completion: completion)
        }
    }
    
    static func unfollow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(currentUid).collection("following").document(uid).delete { (error) in
            if let e = error {
                print("There was an error deleting the follower for the unfollow API \(e.localizedDescription)")
                return
            }
            COLLECTION_FOLLOWED.document(uid).collection("followers").document(currentUid).delete(completion: completion)
        }
    }
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(currentUid).collection("following").document(uid).getDocument { (documentSnapshot, error) in
            if let e = error {
                print("There was an error getting the document for the checkIfUserIsFollowed API \(e.localizedDescription)")
                return
            }
            guard let isFollowed = documentSnapshot?.exists else { return }
            completion(isFollowed)
        }
    }
    
    static func fetchUserStats(uid: String, completion: @escaping(UserStats) -> Void) {
        COLLECTION_FOLLOWED.document(uid).collection("followers").getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an error getting the documents for the followers of the fetchUserStats API \(e.localizedDescription)")
                return
            }
            let follower = querySnapshot?.documents.count ?? 0
            COLLECTION_FOLLOWING.document(uid).collection("following").getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an error getting the documents for the following of the fetchUserStats API \(e.localizedDescription)")
                    return
                }
                let following = querySnapshot?.documents.count ?? 0
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { (querySnapshot, error) in
                    if let e = error {
                        print("There was an error getting the documents under the collection Posts \(e.localizedDescription)")
                        return
                    }
                    let posts = querySnapshot?.documents.count ?? 0
                    completion(UserStats(follower: follower, following: following, posts: posts))
                }
            }
        }
    }
    
    static func blockUser(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("blocked").document(uid).setData([:]) { (error) in
            if let e = error {
                print("There was an error blocking the user in the Firebase database \(e.localizedDescription)")
                return
            }
            COLLECTION_USERS.document(uid).collection("gotBlockedBy").document(currentUid).setData([:], completion: completion)
        }
    }
    
    static func unblockUser(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("blocked").document(uid).delete { (error) in
            if let e = error {
                print("There was an error unblocking the user in the Firebase database \(e.localizedDescription)")
                return
            }
            COLLECTION_USERS.document(uid).collection("gotBlockedBy").document(currentUid).delete(completion: completion)
        }
    }
    
    static func checkIfUserIsBlocked(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("blocked").document(uid).getDocument { (documentSnapshot, error) in
            if let e = error {
                print("There was an error getting the docuemnt for the checkIfUserIsBlocked API \(e.localizedDescription)")
                return
            }
            guard let isBlocked = documentSnapshot?.exists else { return }
            completion(isBlocked)
        }
    }
    
    // MARK: - BlockedUsersController APIs
    
    static func fetchBlockedUsers(completion: @escaping([User]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("blocked").getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an error getting the documents for the blocked users \(e.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else { return }
            print("documents are \(documents)")
            let documentID = documents.map({ $0.documentID })
            print("documentIDs are \(documentID)")
            let users = documents.map({ User(dictionary: $0.data() )})
            print("users are \(users)")
            
            COLLECTION_USERS.whereField("uid", in: documentID).getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an error getting the documents for the blocked users \(e.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else { return }
                let users = documents.map({ User(dictionary: $0.data()) })
                completion(users)
            }
        }
    }
    
    static func fetchGotBlockedByUsers(completion: @escaping([User]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("gotBlockedBy").getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an error getting the documents for the blocked users \(e.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else { return }
            print("documents are \(documents)")
            let documentID = documents.map({ $0.documentID })
            print("documentIDs are \(documentID)")
            let users = documents.map({ User(dictionary: $0.data() )})
            print("users are \(users)")
            
            COLLECTION_USERS.whereField("uid", in: documentID).getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an error getting the documents for the blocked users \(e.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else { return }
                let users = documents.map({ User(dictionary: $0.data()) })
                completion(users)
            }
        }
    }
    
    static func checkBlockedAndGotBlockedByUsers(completion: @escaping(Int) -> Void) {
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
    
    static func checkIfProfileIsCurrentUser(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.whereField("uid", isEqualTo: currentUid).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            let documentID = documents.map({ $0.documentID })
            print(documentID)
            
            COLLECTION_USERS.document(uid).getDocument { (documentSnapshot, error) in
                if documentID.contains(uid) {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}


