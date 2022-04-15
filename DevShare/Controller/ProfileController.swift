//
//  ProfileController.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit
import Firebase

private let profileHeaderIdentifier = "ProfileHeader"
private let profileCellIdentifier = "ProfileCell"

class ProfileController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var user: User
    private var posts = [Post]()
    
    // MARK: - Lifecycles
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProfilePostsAPI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        checkIfUserIsLoggedInAPI()
        fetchUserStatsAPI()
        fetchProfilePostsAPI()
    }
    
    // MARK: - APIs
    
    func checkIfUserIsLoggedInAPI() {
        UserService.checkIfUserIsFollowed(uid: user.uid) { (isFollowed) in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStatsAPI() {
        UserService.fetchUserStats(uid: user.uid) { (userStats) in
            self.user.userStats = userStats
            self.collectionView.reloadData()
        }
    }
    
    func fetchProfilePostsAPI() {
        PostService.fetchProfilePosts(forUser: user.uid) { (posts) in
            self.posts = posts
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @objc func menu() {
        let menuController = MenuController()
        navigationController?.pushViewController(menuController, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(menu))
        
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        collectionView.backgroundColor = .white
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileHeaderIdentifier)
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: profileCellIdentifier)
    }
    
}

// MARK: - UICollectionViewDataSource

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileHeaderIdentifier, for: indexPath) as! ProfileHeader
        profileHeader.profileHeaderViewModel = ProfileHeaderViewModel(user: user)
        profileHeader.profileHeaderDelegate = self
        return profileHeader
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCellIdentifier, for: indexPath) as! ProfileCell
        profileCell.postViewModel = PostViewModel(post: posts[indexPath.row])
        return profileCell
    }
}

// MARK: - UICollectionVIewDelegate

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedController = FeedController(user: user)
        feedController.post = posts[indexPath.row]
        navigationController?.pushViewController(feedController, animated: true)
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 320)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
}

// MARK: - ProfileHeaderDelegate

extension ProfileController: ProfileHeaderDelegate {
    func showAlertController(_ header: ProfileHeader, report user: User) {
        UserService.checkIfProfileIsCurrentUser(uid: user.uid) { (bool) in
            if bool {
                print("Current Post")
            } else {
                let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                UserService.checkIfUserIsBlocked(uid: user.uid) { isBlocked in
                    if isBlocked {
                        print("B")
                        ac.addAction(UIAlertAction(title: "Unblock User", style: .destructive, handler: { (_) in
                            UserService.unblockUser(uid: user.uid) { (error) in
                                if let e = error {
                                    print("There was an error unblocking the user \(e.localizedDescription)")
                                    return
                                }
                                print("Successfully unblocked the user in the Firebase database")
                            }
                        }))
                    } else {
                        print("A")
                        print(isBlocked)
                        ac.addAction(UIAlertAction(title: "Block User", style: .destructive, handler: { (_) in
                            UserService.blockUser(uid: user.uid) { (error) in
                                if let e = error {
                                    print("There was an error blocking the user \(e.localizedDescription)")
                                    return
                                }
                                print("Successfully blocked the user to the Firebase database")
                            }
                        }))
                    }
                }
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
    
    func header(_ profileHeader: ProfileHeader, _ user: User) {
        if user.isCurrentUser {
            print("Show Edit Profile")
        } else if user.isFollowed {
            UserService.unfollow(uid: user.uid) { (error) in
                if let e = error {
                    print("There was an error unfollowing the user \(e.localizedDescription)")
                    return
                }
                self.user.isFollowed = false
                self.fetchUserStatsAPI()
                self.collectionView.reloadData()
            }
        } else {
            UserService.follow(uid: user.uid) { (error) in
                if let e = error {
                    print("There was an error following the user \(e.localizedDescription)")
                    return
                }
                self.user.isFollowed = true
                self.fetchUserStatsAPI()
                self.collectionView.reloadData()
            }
        }
    }
}
