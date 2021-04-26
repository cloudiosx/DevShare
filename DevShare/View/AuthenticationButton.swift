//
//  AuthenticationButton.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

class AuthenticationButton: UIButton {
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.5)
        layer.cornerRadius = 5
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        setTitleColor(.white, for: .normal)
        isEnabled = false
        setHeight(50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
