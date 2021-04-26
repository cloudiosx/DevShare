//
//  RegistrationController.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    private var registrationViewModel = RegistrationViewModel()
    var profileImage: UIImage?
    
    weak var authenticationDelegate: AuthenticationDelegate?
    
    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAddPhoto), for: .touchUpInside)
        return button
    }()
    
    private let emailTextfield: UITextField = {
        let textfield = CustomTextField(placeholder: "Email")
        textfield.keyboardType = .emailAddress
        return textfield
    }()
    
    private let passwordTextfield: UITextField = {
        let textfield = CustomTextField(placeholder: "Password")
        textfield.isSecureTextEntry = true
        return textfield
    }()
    
    private let usernameTextfield = CustomTextField(placeholder: "Username")
    private let fullnameTextfield = CustomTextField(placeholder: "Fullname")
    
    private let signUpButton: UIButton = {
        let button = AuthenticationButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setHeight(50)
        button.attributedTitle(firstPart: "Already have an account", secondPart: "Login here")
        button.addTarget(self, action: #selector(handleShowLoginController), for: .touchUpInside)
        return button
    }()
    
    private let checkbox: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "dry-clean"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(checkIfChecked), for: .touchUpInside)
        return button
    }()
    
    private let labelA: UILabel = {
        let label = UILabel()
        label.text = "I accept the "
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let labelB: UILabel = {
        let label = UILabel()
        label.text = "and "
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let tcButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Terms & Conditions ", for: .normal)
        button.addTarget(self, action: #selector(didTapTCButton), for: .touchUpInside)
        button.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    
    private let ppButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Privacy Policy ", for: .normal)
        button.addTarget(self, action: #selector(didTapPPButton), for: .touchUpInside)
        button.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        configureUI()
        configureTextFieldObservers()
    }
    
    // MARK: - Actions
    
    @objc func handleSignIn() {
        guard let email = emailTextfield.text else { return }
        guard let password = passwordTextfield.text else { return }
        guard let fullname = fullnameTextfield.text else { return }
        guard let username = usernameTextfield.text else { return }
        guard let profileImage = self.profileImage else { return }
        
        let authCredentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        
        AuthService.registerUser(withCredentials: authCredentials) { (error) in
            if let e = error {
                print("There was an error registering the user \(e.localizedDescription)")
                return
            }
            
            self.authenticationDelegate?.authenticationDidComplete()
        }
    }
    
    @objc func handleAddPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    @objc func observer(sender: UITextField) {
        if sender == emailTextfield {
            registrationViewModel.email = sender.text
        } else if sender == passwordTextfield {
            registrationViewModel.password = sender.text
        } else if sender == usernameTextfield {
            registrationViewModel.username = sender.text
        } else {
            registrationViewModel.fullname = sender.text
        }
        
        updateForm()
    }
    
    @objc func handleShowLoginController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func checkIfChecked() {
        var checked = false
        if checkbox.currentImage == #imageLiteral(resourceName: "dry-clean") {
            checkbox.setImage(#imageLiteral(resourceName: "verified"), for: .normal)
            checked = true
            registrationViewModel.checkboxIsChecked = checked
        } else {
            checkbox.setImage(#imageLiteral(resourceName: "dry-clean"), for: .normal)
            checked = false
            registrationViewModel.checkboxIsChecked = checked
        }
        
        updateForm()
    }
    
    @objc func didTapTCButton() {
        UIApplication.shared.open(URL(string: "https://www.iubenda.com/terms-and-conditions/24781390")! as URL, options: [:], completionHandler: nil)
    }
    
    @objc func didTapPPButton() {
        UIApplication.shared.open(URL(string: "https://www.iubenda.com/privacy-policy/24781390")! as URL, options: [:], completionHandler: nil)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        configureGradientLayer()
        
        view.addSubview(addPhotoButton)
        addPhotoButton.centerX(inView: view)
        addPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        addPhotoButton.setDimensions(height: 140, width: 140)
        
        registrationTextfields()
    }
    
    func registrationTextfields() {
        let checkBoxTextStackView = UIStackView(arrangedSubviews: [labelA, tcButton, labelB, ppButton])
        checkBoxTextStackView.axis = .horizontal
        checkBoxTextStackView.distribution = .equalSpacing
        
        let spacer = UIView()
        spacer.setDimensions(height: 30, width: 20)
        
        let horizontalStackView = UIStackView(arrangedSubviews: [spacer, checkbox, checkBoxTextStackView])
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .equalSpacing
        horizontalStackView.spacing = 5

        let stackview = UIStackView(arrangedSubviews: [emailTextfield, passwordTextfield, usernameTextfield, fullnameTextfield, horizontalStackView, signUpButton, alreadyHaveAccountButton])
        stackview.axis = .vertical
        stackview.spacing = 20
        
        view.addSubview(stackview)
        stackview.anchor(top: addPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
    }
    
    func configureTextFieldObservers() {
        emailTextfield.addTarget(self, action: #selector(observer), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(observer), for: .editingChanged)
        usernameTextfield.addTarget(self, action: #selector(observer), for: .editingChanged)
        fullnameTextfield.addTarget(self, action: #selector(observer), for: .editingChanged)
    }
    
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension RegistrationController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        profileImage = selectedImage
        registrationViewModel.profileImage = profileImage
        
        updateForm()
        
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.width / 2
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.layer.borderColor = UIColor.white.cgColor
        addPhotoButton.layer.borderWidth = 2
        addPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)

        dismiss(animated: true, completion: nil)
    }
}

// MARK: - FormViewModel

extension RegistrationController: FormViewModel {
    func updateForm() {
        signUpButton.backgroundColor = registrationViewModel.buttonBackgroundColor
        signUpButton.setTitleColor(registrationViewModel.buttonTextColor, for: .normal)
        signUpButton.isEnabled = registrationViewModel.formIsValid
    }
}
