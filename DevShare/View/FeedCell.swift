//
//  FeedCell.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

protocol FeedCellDelegate: class {
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post)
    func cell(_ cell: FeedCell, didLike post: Post)
    func showAlertController(_ cell: FeedCell, report post: Post)
}

class FeedCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var postViewModel: PostViewModel? {
        didSet {
            configurePostViewModel()
        }
    }
    
    weak var delegate: FeedCellDelegate?
    
    private let profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        imageview.isUserInteractionEnabled = true
        return imageview
    }()
    
    private lazy var username: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(tapUsername), for: .touchUpInside)
        return button
    }()
    
    private let postImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        imageview.isUserInteractionEnabled = true
        return imageview
    }()
    
    lazy var like: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var response: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "chat"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapComments), for: .touchUpInside)
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    private let postTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "3 days ago"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    lazy var report: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(reportPost), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCollectionViewCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func didTapComments() {
        guard let postViewModel = postViewModel else { return }
        delegate?.cell(self, wantsToShowCommentsFor: postViewModel.post)
    }
    
    @objc func tapUsername() {
        print("Did tap username")
    }
    
    @objc func didTapLike() {
        guard let postViewModel = postViewModel else { return }
        delegate?.cell(self, didLike: postViewModel.post)
    }
    
    @objc func reportPost() {
        guard let postViewModel = postViewModel else { return }
        delegate?.showAlertController(self, report: postViewModel.post)
    }
    
    // MARK: - Helpers
    
    func configurePostViewModel() {
        guard let safelyUnwrappedViewModel = postViewModel else { return }
        postImageView.sd_setImage(with: safelyUnwrappedViewModel.imageUrl)
        likesLabel.text = "\(safelyUnwrappedViewModel.likes) likes"
        captionLabel.text = safelyUnwrappedViewModel.caption
        
        profileImageView.sd_setImage(with: safelyUnwrappedViewModel.userProfileImageUrl)
        username.setTitle(safelyUnwrappedViewModel.username, for: .normal)
        likesLabel.text = safelyUnwrappedViewModel.likesLabelText
        
        like.tintColor = safelyUnwrappedViewModel.likeButtonTintColor
        like.setImage(safelyUnwrappedViewModel.likeButtonImage, for: .normal)
    }
    
    func configureCollectionViewCell() {
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: safeAreaLayoutGuide.topAnchor, paddingTop: 24)
        profileImageView.centerX(inView: self)
        profileImageView.setDimensions(height: 80, width: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        addSubview(username)
        username.centerX(inView: profileImageView)
        username.anchor(top: profileImageView.bottomAnchor, paddingTop: 24)
        
        addSubview(report)
        report.anchor(top: profileImageView.bottomAnchor, right: rightAnchor, paddingTop: 24, paddingRight: 24)
        
        addSubview(postImageView)
        postImageView.anchor(top: username.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 24)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureButtonStackview()
        configureLabelStackview()
    }
    
    func configureButtonStackview() {
        let stackview = UIStackView(arrangedSubviews: [like, response])
        stackview.axis = .horizontal
        stackview.distribution = .fillEqually
        
        addSubview(stackview)
        stackview.anchor(top: postImageView.bottomAnchor, paddingTop: 8)
        stackview.centerX(inView: postImageView)
        stackview.setDimensions(height: 50, width: 120)
    }
    
    func configureLabelStackview() {
        let stackview = UIStackView(arrangedSubviews: [likesLabel, captionLabel, postTimeLabel])
        stackview.axis = .vertical
        stackview.distribution = .fillEqually
        stackview.spacing = 10
        
        addSubview(stackview)
        stackview.anchor(top: like.bottomAnchor, paddingTop: -4)
        stackview.centerX(inView: profileImageView)
    }
    
}
