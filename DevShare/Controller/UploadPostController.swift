//
//  UploadPostController.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

protocol UploadPostControllerDelegate: class {
    func uploadPostDidComplete(_ controller: UploadPostController)
}

class UploadPostController: UIViewController {
    
    // MARK: - Properties
    
    var selectedImage: UIImage? {
        didSet {
            photoImageView.image = selectedImage
        }
    }
    
    var currentUser: User?
    
    weak var uploadPostControllerDelegate: UploadPostControllerDelegate?
    
    private let photoImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        return imageview
    }()
    
    private lazy var captionTextView: UITextView = {
        let textview = InputTextView()
        textview.placeholderText = "Enter caption here..."
        textview.font = UIFont.systemFont(ofSize: 16)
        textview.delegate = self
        textview.placeholderShouldCenter = false
        return textview
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0/100"
        return label
    }()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Actions
    
    @objc func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapDone() {
        guard let safelyUnwrappedSelectedImage = selectedImage else { return }
        guard let safelyUnwrappedUser = currentUser else { return }
        showLoader(true)
        PostService.uploadPost(captionTextView.text, safelyUnwrappedSelectedImage, safelyUnwrappedUser) { (error) in
            self.showLoader(false)
            if let e = error {
                print("There was an error uploading the user's post \(e.localizedDescription)")
                return
            }
            
            self.uploadPostControllerDelegate?.uploadPostDidComplete(self)
        }
    }
    
    // MARK: - Helpers
    
    func checkMaxLength(_ textview: UITextView, _ maxlength: Int) {
        if textview.text.count > maxlength {
            textview.deleteBackward()
        }
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Upload Post"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(didTapDone))
        
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        photoImageView.centerX(inView: view)
        photoImageView.setDimensions(height: 180, width: 180)
        photoImageView.layer.cornerRadius = 10
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingRight: 12, height: 64)
        
        view.addSubview(characterCountLabel)
        characterCountLabel.anchor(bottom: captionTextView.bottomAnchor, right: view.rightAnchor, paddingBottom: -8, paddingRight: 12)
    }
}

// MARK: - UITextViewDelegate

extension UploadPostController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLength(textView, 100)
        characterCountLabel.text = "\(textView.text.count)/100"
    }
}
