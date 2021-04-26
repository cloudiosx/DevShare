//
//  AuthService.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static func registerUser(withCredentials credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        ImageUploader.uploadImage(image: credentials.profileImage) { (imageUrl) in
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (authDataResult, error) in
                if let e = error {
                    print("There was an error creating the user \(e.localizedDescription)")
                    return
                }
                
                guard let uid = authDataResult?.user.uid else { return }
                
                let data: [String: Any] = ["email": credentials.email,
                                           "password": credentials.password,
                                           "fullname": credentials.fullname,
                                           "uid": uid,
                                           "username": credentials.username,
                                           "profileImageUrl": imageUrl]
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
        }
    }
    
    static func logUserIn(withEmail email: String, withPassword password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
}
