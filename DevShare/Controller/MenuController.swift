//
//  MenuController.swift
//  DevShare
//
//  Created by John Kim on 3/29/21.
//

import UIKit
import Firebase

private let tableViewCellIdentifier = "TableViewCell"

class MenuController: UITableViewController {
    
    // MARK: - Properties
    
    let menuItems: [String] = ["Logout", "Terms & Conditions", "Privacy Policy", "Blocked Users"]
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        configureUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        title = "Settings"
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
        tableView.rowHeight = 64
    }
}

// MARK: - UITableViewDataSource

extension MenuController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath)
        tableViewCell.textLabel?.text = menuItems[indexPath.row]
        return tableViewCell
    }
}

// MARK: - UITableViewDelegate

extension MenuController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                loginController.authenticationDelegate = tabBarController as? TabBarController
                let navigationController = UINavigationController(rootViewController: loginController)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            } catch {
                print("Error signing out")
            }
        } else if indexPath.row == 1 {
            UIApplication.shared.open(URL(string: "https://www.iubenda.com/terms-and-conditions/24781390")! as URL, options: [:], completionHandler: nil)
        } else if indexPath.row == 2 {
            UIApplication.shared.open(URL(string: "https://www.iubenda.com/privacy-policy/24781390")! as URL, options: [:], completionHandler: nil)
        } else {
            let blockedUsersController = BlockedUsersController()
            navigationController?.pushViewController(blockedUsersController, animated: true)
        }
    }
}
