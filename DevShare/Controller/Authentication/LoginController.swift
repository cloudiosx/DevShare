//
//  LoginController.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

protocol AuthenticationDelegate: class {
    func authenticationDidComplete()
}

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    private var loginViewModel = LoginViewModel()
    
    weak var authenticationDelegate: AuthenticationDelegate?
    
    private let appShareLogo: UIImageView = {
        let imageview = UIImageView(image: #imageLiteral(resourceName: "LogoMakr-58uXE2"))
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()
    
    private let emailTextField: UITextField = {
        let textfield = CustomTextField(placeholder: "Email")
        textfield.keyboardType = .emailAddress
        return textfield
    }()
    
    private let passwordTextField: UITextField = {
        let textfield = CustomTextField(placeholder: "Password")
        textfield.isSecureTextEntry = true
        return textfield
    }()
    
    private let loginButton: UIButton = {
        let button = AuthenticationButton()
        button.setTitle("Log In", for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setHeight(50)
        button.attributedTitle(firstPart: "Don't have an account?", secondPart: "Sign up here")
        button.addTarget(self, action: #selector(handleShowRegistrationController), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        configureUI()
        configureTextFieldObservers()
    }
    
    // MARK: - Actions
    
    @objc func handleLogin() {
        guard let email = emailTextField.text?.lowercased() else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthService.logUserIn(withEmail: email, withPassword: password) { (authDataResult, error) in
            if let e = error {
                print("There was an error logging the user in \(e.localizedDescription)")
                return
            }
            
            self.authenticationDelegate?.authenticationDidComplete()
        }
    }
    
    @objc func handleShowRegistrationController() {
        let registrationController = RegistrationController()
        registrationController.authenticationDelegate = authenticationDelegate
        navigationController?.pushViewController(registrationController, animated: true)
    }
    
    @objc func observer(sender: UITextField) {
        if sender == emailTextField {
            loginViewModel.email = sender.text
        } else {
            loginViewModel.password = sender.text
        }
        
        updateForm()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        configureGradientLayer()
        configureNavigationBar()
        
        view.addSubview(appShareLogo)
        appShareLogo.centerX(inView: view)
        appShareLogo.setDimensions(height: 50, width: 70)
        appShareLogo.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 50)
        
        configureAuthenticationStackview()
        
//        view.addSubview(dontHaveAccountButton)
//        dontHaveAccountButton.centerX(inView: view)
//        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    func configureAuthenticationStackview() {
        let stackview = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, dontHaveAccountButton])
        stackview.axis = .vertical
        stackview.spacing = 20
        
        view.addSubview(stackview)
        stackview.anchor(top: appShareLogo.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
    }
    
    func configureTextFieldObservers() {
        emailTextField.addTarget(self, action: #selector(observer), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(observer), for: .editingChanged)
    }
    
}

extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = loginViewModel.buttonBackgroundColor
        loginButton.setTitleColor(loginViewModel.buttonTextColor, for: .normal)
        loginButton.isEnabled = loginViewModel.formIsValid
    }
}
