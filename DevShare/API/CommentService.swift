//
//  CommentService.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import Firebase

struct CommentService {
    
    static func uploadComment(comment: String, postID: String, user: User, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let data: [String: Any] = ["uid": user.uid,
                                   "comment": comment,
                                   "timestamp": Timestamp(date: Date()),
                                   "username": user.username,
                                   "profileImageUrl": user.profileImageUrl,
                                   "reports": 0]
        
        COLLECTION_POSTS.document(postID).collection("comments").document(currentUid).setData(data, completion: completion)
        
    }
    
    static func fetchComments(forPost postID: String, completion: @escaping([Comment]) -> Void) {
        var comments = [Comment]()
        let query = COLLECTION_POSTS.document(postID).collection("comments").order(by: "timestamp", descending: true)
        query.addSnapshotListener { (querySnapshot, error) in
            querySnapshot?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    let data = change.document.data()
                    let comment = Comment(dictionary: data)
                    comments.append(comment)
                }
            })
            
            completion(comments)
        }
    }
    
    static func reportComment(comment: Comment, postID: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_POSTS.document(postID).collection("comments").document(currentUid).updateData(["reports": comment.reports + 1])
        print("A")
        COLLECTION_POSTS.document(postID).collection("comment-reports").document(currentUid).setData([:]) { (_) in
            COLLECTION_POSTS.document(postID).collection("comment-reports").document(currentUid).setData([:], completion: completion)
        }
        print("B")
    }
    
    static func checkifCommentIsCurrentUser(comment: Comment, postID: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_POSTS.document(postID).collection("comments").whereField("uid", isEqualTo: currentUid).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            let querySnapshotDocumentID = documents.map({ $0.documentID })
            print(querySnapshotDocumentID)
            
            COLLECTION_POSTS.document(postID).collection("comments").document(comment.uid).getDocument { (documentSnapshot, error) in
                guard let documentSnapshotDocumentID = documentSnapshot?.documentID else { return }
                print(documentSnapshotDocumentID)
                
                if querySnapshotDocumentID.contains(documentSnapshotDocumentID) {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
