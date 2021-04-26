//
//  ProfileCell.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var postViewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    private let postImageView: UIImageView = {
        let imageview = UIImageView(image: #imageLiteral(resourceName: "anthony-delanoix-Q0-fOL2nqZc-unsplash"))
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        return imageview
    }()
    
    // MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let safelyUnwrappedPostViewModel = postViewModel else { return }
        postImageView.sd_setImage(with: safelyUnwrappedPostViewModel.imageUrl)
    }
    
}
