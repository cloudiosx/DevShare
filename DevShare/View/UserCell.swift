//
//  UserCell.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

class UserCell: UITableViewCell {
    
    // MARK: - Properties
    
    var userCellViewModel: UserCellViewModel? {
        didSet {
            configure()
        }
    }
    
    private let profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        imageview.backgroundColor = .lightGray
        return imageview
    }()
    
    private let username: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let fullname: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Lifecycles
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.layer.cornerRadius = 48 / 2
        
        stackview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let safelyUnwrappedViewModel = userCellViewModel else { return }
        profileImageView.sd_setImage(with: safelyUnwrappedViewModel.profileImageUrl)
        username.text = safelyUnwrappedViewModel.username
        fullname.text = safelyUnwrappedViewModel.fullname
    }
    
    func stackview() {
        let stackview = UIStackView(arrangedSubviews: [username, fullname])
        stackview.axis = .vertical
        stackview.spacing = 4
        stackview.alignment = .leading
        
        addSubview(stackview)
        stackview.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
    }
    
}
