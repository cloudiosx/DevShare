//
//  CommentCell.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

protocol CommentCellDelegate: class {
    func showAlertController(_ cell: CommentCell, report comment: Comment)
}

class CommentCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var commentViewModel: CommentViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: CommentCellDelegate?
    
    private let profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        imageview.backgroundColor = .lightGray
        return imageview
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var report: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(reportComment), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func reportComment() {
        guard let commentViewModel = commentViewModel else { return }
        delegate?.showAlertController(self, report: commentViewModel.comment)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let safelyUnwrappedViewModel = commentViewModel else { return }
        profileImageView.sd_setImage(with: safelyUnwrappedViewModel.profileImageUrl)
        commentLabel.attributedText = safelyUnwrappedViewModel.commentLabelText()
    }
    
    func configureUI() {
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 8)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(commentLabel)
        commentLabel.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        commentLabel.anchor(right: rightAnchor, paddingRight: 8)
        
        addSubview(report)
        report.centerY(inView: self)
        report.anchor(right: rightAnchor, paddingRight: 8)
    }
}
