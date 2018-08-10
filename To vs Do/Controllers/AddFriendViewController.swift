//
//  AddFriendViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/31/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator

class AddFriendViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addFriendsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    var users = [User]() {
        didSet {
            usernames = []
            for user in users{
                usernames.append(user.username)
            }
        }
    }
    var usernames = [String]() {
        didSet {
            searchResultsTableView.reloadData()
        }
    }
    
    var filteredUsernames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsTableView.isHidden = true
        
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        self.searchBar.inputAccessoryView = toolbar
        
        addFriendsTableView.tableFooterView = UIView()
        
    }
    
    @objc func doneButtonAction() {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchResultsTableView.isHidden = true
        searchBar.text = ""
        UserService.usersExcludingCurrentUser { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.addFriendsTableView.reloadData()
            }
        }
        filteredUsernames = usernames
        searchResultsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserService.usersExcludingCurrentUser { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.addFriendsTableView.reloadData()
            }
        }
        
        filteredUsernames = usernames
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUsernames = searchText.isEmpty ? usernames : usernames.filter({(dataString: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return dataString.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        searchResultsTableView.reloadData()
    }
    

    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResultsTableView.isHidden = true
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        UserService.usersExcludingCurrentUser { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.addFriendsTableView.reloadData()
            }
        }
        filteredUsernames = usernames
        searchResultsTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchResultsTableView.isHidden = false
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResultsTableView.isHidden = true
        searchBar.setShowsCancelButton(false, animated: true)
        if(searchBar.text != nil) {
            UserService.searchForNewFriend(username: searchBar.text!) { [unowned self] (users) in
                self.users = users
                
                DispatchQueue.main.async {
                    self.addFriendsTableView.reloadData()
                }
            }
        }
        filteredUsernames = usernames
        searchResultsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == self.addFriendsTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendTableViewCell", for: indexPath) as! AddFriendTableViewCell
            cell.delegate = self
            configure(cell: cell, atIndexPath: indexPath)
            return cell
        } else {
            let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
            cell.textLabel?.text = filteredUsernames[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView == self.searchResultsTableView) {
            UserService.searchForNewFriend(username: filteredUsernames[indexPath.row]) { [unowned self] (users) in
                self.users = users
                    
                DispatchQueue.main.async {
                    self.addFriendsTableView.reloadData()
                }
            }
            searchBar.resignFirstResponder()
            searchResultsTableView.isHidden = true
            searchBar.setShowsCancelButton(false, animated: true)
            filteredUsernames = usernames
            searchResultsTableView.reloadData()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count: Int?
        
        if(tableView == self.addFriendsTableView) {
            count = users.count
        }
        
        if(tableView == self.searchResultsTableView) {
            count = filteredUsernames.count
        }
        
        return count!
    }
    
    func configure(cell: AddFriendTableViewCell, atIndexPath indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        cell.addFriendUsernameLabel.text = user.username
        cell.addFriendProfileImageView.af_setImage(withURL: URL(string: user.profilePic)!)
        cell.addFriendButton.isSelected = user.isFriend
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Report as Inappropriate") { (action, indexPath) in
            let alertController = UIAlertController(title: nil, message: "Are you sure you want to report this user for inapporpiate content?", preferredStyle: .alert)
            
            let reportAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
                let flaggedUser = self.users[indexPath.row]
                let flaggedUserRef = Database.database().reference().child("flaggedUsers").child(flaggedUser.uid)
                let flaggedDict = ["image_url" : flaggedUser.profilePic,
                                   "username" : flaggedUser.username,
                                   "reporter_uids/\(User.current.uid)": true] as [String : Any]
                flaggedUserRef.updateChildValues(flaggedDict)
                
                let flagCountRef = flaggedUserRef.child("flag_count")
                flagCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                    let currentCount = mutableData.value as? Int ?? 0
                    
                    mutableData.value = currentCount + 1
                    
                    return TransactionResult.success(withValue: mutableData)
                })
            })
            alertController.addAction(reportAction)
            
            let declineAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alertController.addAction(declineAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.897116363, green: 0.1273201406, blue: 0, alpha: 1)
        
        return [delete]
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


