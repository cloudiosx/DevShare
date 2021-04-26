//
//  CommentController.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

private let reuseIdentifier = "CommentCell"

class CommentController: UICollectionViewController {
    
    // MARK: - Properties
    
    private let post: Post
    private var comments = [Comment]()
    
    private lazy var commentInputAccessoryView: UIView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()
    
    // MARK: - Lifecycles
    
    init(post: Post) {
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchComments()
    }
    
    override var inputAccessoryView: UIView? {
        get { return commentInputAccessoryView}
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - APIs
    
    func fetchComments() {
        CommentService.fetchComments(forPost: post.postID) { (comments) in
            self.comments = comments
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
    
    
}

// MARK: - UICollectionViewDataSource

extension CommentController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.delegate = self
        cell.commentViewModel = CommentViewModel(comment: comments[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CommentController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let commentUid = comments[indexPath.row].uid
        UserService.fetchUser(withUid: commentUid) { (user) in
            let profileController = ProfileController(user: user)
            self.navigationController?.pushViewController(profileController, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CommentController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let commentViewModel = CommentViewModel(comment: comments[indexPath.row])
        let height = commentViewModel.size(forWidth: view.frame.width).height + 32
        return CGSize(width: view.frame.width, height: height)
    }
}

// MARK: - CommentInputAccessoryViewDelegate

extension CommentController: CommentInputAccessoryViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        print("Comment is \(comment)")
        
        guard let tabBarController = tabBarController as? TabBarController else { return }
        guard let user = tabBarController.user else { return }
        
        showLoader(true)
        
        CommentService.uploadComment(comment: comment, postID: post.postID, user: user) { (error) in
            self.showLoader(false)
            inputView.clearCommentTextView()
        }
    }
}

// MARK: - CommentCellDelegate

extension CommentController: CommentCellDelegate {
    func showAlertController(_ cell: CommentCell, report comment: Comment) {
        CommentService.checkifCommentIsCurrentUser(comment: comment, postID: self.post.postID) { (bool) in
            if bool {
                print("Current user's comment")
            } else {
                let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                ac.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (_) in
                    CommentService.reportComment(comment: comment, postID: self.post.postID) { (error) in
                        if let e = error {
                            print("There was an error reporting the post \(e.localizedDescription)")
                            return
                        }
                        cell.commentViewModel?.comment.reports = comment.reports + 1
                        print("Successfully reported a comment")
                    }
                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
}
