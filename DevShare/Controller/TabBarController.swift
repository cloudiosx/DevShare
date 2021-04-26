//
//  TabBarController.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit
import Firebase
import YPImagePicker

class TabBarController: UITabBarController {
    
    // MARK: - Properties
    
    private var registrationViewModel = RegistrationViewModel()
    var user: User? {
        didSet {
            guard let unwrappedUser = user else { fatalError("Not working") }
            configureViewControllers(withUser: unwrappedUser)
        }
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedInAPI()
        fetchUserAPI()
    }
    
    // MARK: - APIs
    
    func fetchUserAPI() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(withUid: currentUid) { (user) in
            self.user = user
        }
    }
    
    func checkIfUserIsLoggedInAPI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                loginController.authenticationDelegate = self
                let navigationController = UINavigationController(rootViewController: loginController)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        } else {
            print("Not working")
        }
    }
    
    // MARK: - Helpers
    
    func configureViewControllers(withUser user: User) {
        self.delegate = self
        
        let feedController = navigationController(rootViewController: FeedController(user: user), unselectedImage: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "home copy"), title: "Feed")
        let searchController = navigationController(rootViewController: SearchController(), unselectedImage: #imageLiteral(resourceName: "search"), selectedImage: #imageLiteral(resourceName: "search copy"), title: "Search")
        let imageSelectorController = navigationController(rootViewController: ImageSelectorController(), unselectedImage: #imageLiteral(resourceName: "upload"), selectedImage: #imageLiteral(resourceName: "upload"), title: "Upload")
        
        let profileController = navigationController(rootViewController: ProfileController(user: user), unselectedImage: #imageLiteral(resourceName: "user"), selectedImage: #imageLiteral(resourceName: "user (1)"), title: "Profile")
        
        viewControllers = [feedController, searchController, imageSelectorController, profileController]
        
        tabBar.tintColor = .black
        
    }
    
    func navigationController(rootViewController: UIViewController, unselectedImage: UIImage, selectedImage: UIImage, title: String) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.image = unselectedImage
        navigationController.tabBarItem.selectedImage = selectedImage
        navigationController.tabBarItem.title = title
        navigationController.navigationBar.tintColor = .black
        return navigationController
    }
    
    func didFinishPickingMedia(_ picker: YPImagePicker) {
        picker.didFinishPicking { (ypMediaItem, _) in
            picker.dismiss(animated: false) {
                guard let selectedImage = ypMediaItem.singlePhoto?.image else { return }
                
                let uploadPostController = UploadPostController()
                uploadPostController.selectedImage = selectedImage
                uploadPostController.uploadPostControllerDelegate = self
                uploadPostController.currentUser = self.user
                let navigationController = UINavigationController(rootViewController: uploadPostController)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: false, completion: nil)
            }
        }
    }
    
}

// MARK: - AuthenticationDelegate

extension TabBarController: AuthenticationDelegate {
    func authenticationDidComplete() {
        fetchUserAPI()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            var ypImagePickerConfiguration = YPImagePickerConfiguration()
            ypImagePickerConfiguration.library.mediaType = .photo
            ypImagePickerConfiguration.shouldSaveNewPicturesToAlbum = true
            ypImagePickerConfiguration.startOnScreen = .library
            ypImagePickerConfiguration.screens = [.library]
            ypImagePickerConfiguration.hidesStatusBar = false
            ypImagePickerConfiguration.hidesBottomBar = false
            ypImagePickerConfiguration.library.maxNumberOfItems = 5
            
            let ypImagePicker = YPImagePicker(configuration: ypImagePickerConfiguration)
            ypImagePicker.modalPresentationStyle = .fullScreen
            present(ypImagePicker, animated: false, completion: nil)
            
            didFinishPickingMedia(ypImagePicker)
        }
        
        return true
    }
}

// MARK: - UploadPostControllerDelegate

extension TabBarController: UploadPostControllerDelegate {
    func uploadPostDidComplete(_ controller: UploadPostController) {
        guard let safelyUnwrappedUser = user else { return }
        
        selectedIndex = 0
        controller.dismiss(animated: true, completion: nil)
        
        let profileController = ProfileController(user: safelyUnwrappedUser)
        profileController.fetchProfilePostsAPI()
        
        guard let feedNav = viewControllers?.first as? UINavigationController else { return }
        guard let feed = feedNav.viewControllers.first as? FeedController else { return }
        feed.handleRefresh()
    }
}
