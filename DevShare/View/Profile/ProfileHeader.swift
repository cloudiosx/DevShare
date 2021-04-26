//
//  ProfileHeader.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit
import SDWebImage

protocol ProfileHeaderDelegate: class {
    func header(_ profileHeader: ProfileHeader, _ user: User)
    func showAlertController(_ header: ProfileHeader, report user: User)
}

class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Properties
    
    var profileHeaderViewModel: ProfileHeaderViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var profileHeaderDelegate: ProfileHeaderDelegate?
    
    private let profileImageView: UIImageView = {
        let imageview = UIImageView(image: #imageLiteral(resourceName: "anthony-delanoix-Q0-fOL2nqZc-unsplash"))
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        return imageview
    }()
    
    private let username: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollowButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var blockButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(blockUser), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: safeAreaLayoutGuide.topAnchor, paddingTop: 12)
        profileImageView.centerX(inView: self)
        profileImageView.setDimensions(height: 120, width: 120)
        profileImageView.layer.cornerRadius = 120 / 2

        addSubview(username)
        username.anchor(top: profileImageView.bottomAnchor, paddingTop: 12)
        username.centerX(inView: profileImageView)
        
        addSubview(blockButton)
        blockButton.anchor(top: profileImageView.bottomAnchor, right: rightAnchor, paddingTop: 20, paddingRight: 24)
        
        configureUserStatsStackview()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: followingLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 24, paddingLeft: 24, paddingBottom: 24, paddingRight: 24)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func handleEditProfileFollowButton() {
        guard let safelyUnwrappedViewModel = profileHeaderViewModel else { return }
        profileHeaderDelegate?.header(self, safelyUnwrappedViewModel.user)
    }
    
    @objc func blockUser() {
        guard let profileHeaderViewModel = profileHeaderViewModel else { return }
        profileHeaderDelegate?.showAlertController(self, report: profileHeaderViewModel.user)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let safelyUnwrappedViewModel = profileHeaderViewModel else { return }
        
        username.text = safelyUnwrappedViewModel.username
        
        profileImageView.sd_setImage(with: safelyUnwrappedViewModel.profileImageUrl)
        
        followersLabel.attributedText = safelyUnwrappedViewModel.numberOfFollowers
        followingLabel.attributedText = safelyUnwrappedViewModel.numberOfFollowing
        postsLabel.attributedText = safelyUnwrappedViewModel.numberOfPosts
        
        editProfileFollowButton.setTitle(safelyUnwrappedViewModel.followButtonText, for: .normal)
        editProfileFollowButton.setTitleColor(safelyUnwrappedViewModel.followButtonTextColor, for: .normal)
        editProfileFollowButton.backgroundColor = safelyUnwrappedViewModel.followButtonBackgroundColor
    }
    
    func configureUserStatsStackview() {
        let stackview = UIStackView(arrangedSubviews: [followersLabel, followingLabel, postsLabel])
        stackview.axis = .horizontal
        stackview.distribution = .fillEqually
        
        addSubview(stackview)
        stackview.anchor(top: username.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 24, paddingRight: 24, height: 50)
        stackview.centerX(inView: username)
    }
}
