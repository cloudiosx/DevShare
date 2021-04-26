//
//  SearchController.swift
//  DevShare
//
//  Created by John Kim on 2/27/21.
//

import UIKit

private let tableViewCellIdentifier = "TableViewCell"

class SearchController: UITableViewController {
    
    // MARK: - Properties
    
    var users = [User]() {
        didSet {
            tableView.reloadData()
            print("SearchController didSet has been run")
        }
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredUsers = [User]()
    private var inSearchMode: Bool {
        return !searchController.searchBar.text!.isEmpty && searchController.isActive
    }
    
    // MARK: - Lifecycles
    
    override func viewWillAppear(_ animated: Bool) {
        checkIfUserHasBlockedAnyone()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        users.removeAll()
    }
    
    override func viewDidLoad() {
        configureUI()
        configureSearchBar()
        checkIfUserHasBlockedAnyone()
    }
    
    // MARK: - APIs
    
    func fetchAllUsers() {
        UserService.fetchAllUsers { (users) in
            self.users = users
        }
    }
    
    func fetchAllBlockedUsers() {
        UserService.fetchAllBlockedUsers { (users) in
            self.users = users
        }
    }
    
    func fetchAllGotBlockedByUsers() {
        UserService.fetchAllGotBlockedByUsers { (users) in
            self.users = users
        }
    }
    
    func checkIfUserHasBlockedAnyone() {
        UserService.checkIfUserHasBlockedAnyone { (int) in
            if int == 4 {
                self.fetchAllUsers()
                self.tableView.reloadData()
            } else if int == 3 {
                self.fetchAllBlockedUsers()
                self.fetchAllGotBlockedByUsers()
                self.tableView.reloadData()
            } else if int == 2 {
                self.fetchAllGotBlockedByUsers()
                self.tableView.reloadData()
            } else if int == 1 {
                self.fetchAllBlockedUsers()
                self.tableView.reloadData()
            } else {
                print("Error")
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        tableView.backgroundColor = .white
        tableView.register(UserCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
        tableView.rowHeight = 64
    }
    
    func configureSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
}

// MARK: - UITableViewDataSource

extension SearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath) as! UserCell
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        tableViewCell.userCellViewModel = UserCellViewModel(user: user)
        return tableViewCell
    }
}

// MARK: - UITableViewDelegate

extension SearchController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let profileController = ProfileController(user: user)
        navigationController?.pushViewController(profileController, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredUsers = users.filter( { $0.username.lowercased().contains(searchText) || $0.fullname.lowercased().contains(searchText) })
        self.tableView.reloadData()
    }
}
