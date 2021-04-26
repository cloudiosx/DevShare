//
//  BlockedUsersController.swift
//  DevShare
//
//  Created by John Kim on 4/5/21.
//

import UIKit

private let tableViewCellIdentifier = "TableViewCell"

class BlockedUsersController: UITableViewController {
    
    // MARK: - Properties
    
    private var users = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        checkIfUserHasBlockedAnyone()
    }
    
    // MARK: - APIs
    
    func fetchAllBlockedUsers() {
        UserService.fetchBlockedUsers { (users) in
            self.users = users
        }
    }
    
    func fetchAllGotBlockedByUsers() {
        UserService.fetchGotBlockedByUsers { (users) in
            self.users = users
        }
    }
    
    func checkIfUserHasBlockedAnyone() {
        UserService.checkBlockedAndGotBlockedByUsers { (int) in
            if int == 4 {
                self.users = []
                print("A")
            } else if int == 3 {
                self.fetchAllBlockedUsers()
//                self.fetchAllGotBlockedByUsers()
                print("B")
            } else if int == 2 {
//                self.fetchAllGotBlockedByUsers()
                self.users = []
                print("C")
            } else if int == 1 {
                self.fetchAllBlockedUsers()
                print("Users are \(self.users)")
                print("D")
            } else {
                print("Error")
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.register(UserCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
        tableView.rowHeight = 64
    }
}

// MARK: - UITableViewDataSource

extension BlockedUsersController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        tableViewCell.userCellViewModel = UserCellViewModel(user: user)
        return tableViewCell
    }
}

// MARK: - UITableViewDelegate

extension BlockedUsersController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let profileController = ProfileController(user: user)
        navigationController?.pushViewController(profileController, animated: true)
    }
}
