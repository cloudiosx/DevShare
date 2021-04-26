//
//  ImageUploader.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import Firebase

struct ImageUploader {
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let imageJpegData = image.jpegData(compressionQuality: 0.75) else { return }
        let filename = NSUUID().uuidString
        let reference = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        reference.putData(imageJpegData, metadata: nil) { (storageMetadata, error) in
            if let e = error {
                print("There was an error putting the data to the database \(e.localizedDescription)")
                return
            }
            
            reference.downloadURL { (url, error) in
                if let e = error {
                    print("There was an error downloading the URL \(e.localizedDescription)")
                    return
                }
                
                guard let imageUrl = url?.absoluteString else { return }
                completion(imageUrl)
            }
        }
    }
}
