//
//  FeedController.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

private let collectionViewCellIdentifier = "FeedCell"

class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var user: User
    private var posts = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var post: Post?
    
    // MARK: - Lifecycles
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        configureUI()
        checkIfUserHasBlockedAnyone()
    }
    
    // MARK: - Actions
    
    @objc func handleRefresh() {
        posts.removeAll()
        checkIfUserHasBlockedAnyone()
    }
    
    // MARK: - APIs
    
    func fetchPostsAPI() {
        guard post == nil else { return }
        
        PostService.fetchPosts { (posts) in
            self.posts = posts
            self.collectionView.refreshControl?.endRefreshing()
            self.checkIfUserLikedPosts()
        }
    }
    
    func fetchUnblockedUserPostsAPI() {
        PostService.fetchUnblockedUserPosts { (posts) in
            self.posts = posts
            self.collectionView.refreshControl?.endRefreshing()
            self.checkIfUserLikedPosts()
        }
    }
    
    func fetchGotBlockedByPosts() {
        PostService.fetchGotBlockedByPosts { (posts) in
            self.posts = posts
            self.collectionView.refreshControl?.endRefreshing()
            self.checkIfUserLikedPosts()
        }
    }

    func checkIfUserLikedPosts() {
        self.posts.forEach { (post) in
            PostService.checkIfUserLikedPost(post: post) { (didLike) in
                if let index = self.posts.firstIndex(where: { $0.postID == post.postID }) {
                    self.posts[index].didLike = didLike
                }
            }
        }
    }
    
    func checkIfUserHasBlockedAnyone() {
        PostService.checkIfUserHasBlockedAnyone { (int) in
            if int == 4 {
                self.fetchPostsAPI()
            } else if int == 3 {
                self.fetchUnblockedUserPostsAPI()
                self.fetchGotBlockedByPosts()
            } else if int == 2 {
                self.fetchGotBlockedByPosts()
            } else if int == 1 {
                self.fetchUnblockedUserPostsAPI()
            } else {
                print("Error")
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        collectionView.backgroundColor = .white
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier)
        navigationItem.title = "Feed"
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
}

// MARK: - UICollectionViewDataSource

extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post != nil ? 1: posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellIdentifier, for: indexPath) as! FeedCell
        collectionViewCell.delegate = self
        
        if let safelyUnwrappedPost = post {
            collectionViewCell.postViewModel = PostViewModel(post: safelyUnwrappedPost)
        } else {
            collectionViewCell.postViewModel = PostViewModel(post: posts[indexPath.row])
        }
        
        return collectionViewCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 250
        return CGSize(width: width, height: height)
    }
}

// MARK: - FeedCellDelegate

extension FeedController: FeedCellDelegate {
    func showAlertController(_ cell: FeedCell, report post: Post) {
        PostService.checkIfPostIsCurrentuser(post: post) { (bool) in
            if bool {
                print("Current post")
            } else {
                let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //        ac.addAction(UIAlertAction(title: "Do not show me again", style: .default))
                ac.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (_) in
                    PostService.reportPost(post: post) { (error) in
                        if let e = error {
                            print("There was an error reporting the post \(e.localizedDescription)")
                            return
                        }
                        cell.postViewModel?.post.reports = post.reports + 1
                        print("Successfully reported a post")
                    }
                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
    
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post) {
        let controller = CommentController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: FeedCell, didLike post: Post) {
        cell.postViewModel?.post.didLike.toggle()
        if post.didLike {
            PostService.unlikePost(post: post) { (error) in
                if let e = error {
                    print("There was an error unliking a post \(e.localizedDescription)")
                    return
                }
                cell.like.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
                cell.like.tintColor = .black
                cell.postViewModel?.post.likes = post.likes - 1
            }
        } else {
            PostService.likePost(post: post) { (error) in
                if let e = error {
                    print("There was an error liking a post \(e.localizedDescription)")
                    return
                }
                cell.like.setImage(#imageLiteral(resourceName: "heart copy"), for: .normal)
                cell.like.tintColor = .red
                cell.postViewModel?.post.likes = post.likes + 1
            }
        }
    }
}
