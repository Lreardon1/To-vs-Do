//
//  AddFriendViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/31/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator

class AddFriendViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addFriendsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFriendsTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserService.usersExcludingCurrentUser { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.addFriendsTableView.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        UserService.usersExcludingCurrentUser { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.addFriendsTableView.reloadData()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        if(searchBar.text != nil) {
            UserService.searchForNewFriend(username: searchBar.text!) { [unowned self] (users) in
                self.users = users
                
                DispatchQueue.main.async {
                    self.addFriendsTableView.reloadData()
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendTableViewCell", for: indexPath) as! AddFriendTableViewCell
        cell.delegate = self
        configure(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func configure(cell: AddFriendTableViewCell, atIndexPath indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        cell.addFriendUsernameLabel.text = user.username
        cell.addFriendProfileImageView.af_setImage(withURL: URL(string: user.profilePic)!)
        cell.addFriendButton.isSelected = user.isFriend
    }
}

extension AddFriendViewController: AddFriendsTableViewCellDelegate {
    func didTapAddFriendButton(_ addFriendButton: UIButton, on cell: AddFriendTableViewCell) {
        guard let indexPath = addFriendsTableView.indexPath(for: cell) else { return }
        
        addFriendButton.isUserInteractionEnabled = false
        let followee = users[indexPath.row]
        
        FriendsService.sendRequest(!followee.isFriend, fromCurrentUserTo: followee) { (success) in
            defer {
                addFriendButton.isUserInteractionEnabled = true
            }
            
            guard success else { return }
            
            followee.isFriend = !followee.isFriend
            self.addFriendsTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}


