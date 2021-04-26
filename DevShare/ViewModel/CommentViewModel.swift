//
//  CommentViewModel.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

struct CommentViewModel {
    
    var comment: Comment
    
    var profileImageUrl: URL? {
        return URL(string: comment.profileImageUrl)
    }
    
    func commentLabelText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(comment.username) ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedString.append(NSAttributedString(string: comment.comment, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        return attributedString
    }
    
    func size(forWidth width: CGFloat) -> CGSize {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = comment.comment
        label.lineBreakMode = .byWordWrapping
        label.setWidth(width)
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    init(comment: Comment) {
        self.comment = comment
    }
    
}
