//
//  FriendStatsViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/31/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FriendStatsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var friendStatTableView: UITableView!
    @IBOutlet weak var searchFriendsSearchBar: UISearchBar!
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
        self.searchFriendsSearchBar.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        searchFriendsSearchBar.resignFirstResponder()
        searchFriendsSearchBar.setShowsCancelButton(false, animated: true)
        searchResultsTableView.isHidden = true
        searchFriendsSearchBar.text = ""
        UserService.friendsList { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.friendStatTableView.reloadData()
            }
        }
        filteredUsernames = usernames
        searchResultsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserService.friendsList { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.friendStatTableView.reloadData()
            }
        }
        filteredUsernames = usernames
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        UserService.friendsList { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.friendStatTableView.reloadData()
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
            UserService.searchForOldFriend(username: searchBar.text!) { [unowned self] (users) in
                self.users = users
                
                DispatchQueue.main.async {
                    self.friendStatTableView.reloadData()
                }
            }
        }
        filteredUsernames = usernames
        searchResultsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView == self.searchResultsTableView) {
            UserService.searchForOldFriend(username: filteredUsernames[indexPath.row]) { [unowned self] (users) in
                self.users = users
                
                DispatchQueue.main.async {
                    self.friendStatTableView.reloadData()
                }
            }
            searchFriendsSearchBar.resignFirstResponder()
            searchResultsTableView.isHidden = true
            searchFriendsSearchBar.setShowsCancelButton(false, animated: true)
            filteredUsernames = usernames
            searchResultsTableView.reloadData()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count: Int?
        
        if(tableView == self.friendStatTableView) {
            count = users.count
        }
        
        if(tableView == self.searchResultsTableView) {
            count = filteredUsernames.count
        }
        
        return count!
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
        
        let block = UITableViewRowAction(style: .normal, title: "Block User") { (action, indexPath) in
            let alertController = UIAlertController(title: nil, message: "Are you sure you want to block this user?", preferredStyle: .alert)
            
            let blockAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
                let blockedUser = self.users[indexPath.row]
                let blockedUserRef = Database.database().reference().child("blockedUsers").child(User.current.uid)
                let blockedDict = [blockedUser.uid: true]
                
                blockedUserRef.updateChildValues(blockedDict)
                
                FriendsService.setIsFriend(false, fromCurrentUserTo: self.users[indexPath.row]) { (success) in
                    guard success else { return }
                }
                
                UserService.friendsList { [unowned self] (users) in
                    self.users = users
                    
                    DispatchQueue.main.async {
                        self.friendStatTableView.reloadData()
                    }
                }
            })
            alertController.addAction(blockAction)
            
            let declineAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alertController.addAction(declineAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.897116363, green: 0.1273201406, blue: 0, alpha: 1)
        block.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        return [delete, block]
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == self.friendStatTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendStatTableViewCell", for: indexPath) as! FriendStatTableViewCell
            let friend  = users[indexPath.row]
            cell.friendProfileImageView.af_setImage(withURL: URL(string: friend.profilePic)!)
            cell.friendUsernameLabel.text = friend.username
            
            let ref = Database.database().reference().child("stats").child(friend.uid)
            ref.child("completedToday").observeSingleEvent(of: .value) { (snapshot) in
                let count = snapshot.value as? Int
                if let count = count {
                    cell.friendCompletedLabel.text = "Completed: " + String(count)
                } else {
                    cell.friendCompletedLabel.text = "Completed: 0"
                }
            }
            
            ref.child("toDoToday").observeSingleEvent(of: .value) { (snapshot) in
                let count = snapshot.value as? Int
                if let count = count {
                    cell.friendToDoLabel.text = "Due Today: " + String(count)
                } else {
                    cell.friendToDoLabel.text = "Due Today: 0"
                }
            }
            ref.child("totalToDo").observeSingleEvent(of: .value) { (snapshot) in
                let count = snapshot.value as? Int
                if let count = count {
                    cell.friendTotalToDoLabel.text = "Total Due: " + String(count)
                } else {
                    cell.friendTotalToDoLabel.text = "Total Due: 0"
                }
            }
            
            ref.child("dailyAverage").observeSingleEvent(of: .value) { (snapshot) in
                let count = snapshot.value as? Double
                if let count = count {
                    cell.friendAverageLabel.text = "Average: " + String(count)
                } else {
                    cell.friendAverageLabel.text = "Average: 0"
                }
            }
            return cell
        } else {
            let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
            cell.textLabel?.text = filteredUsernames[indexPath.row]
            return cell
        }
    }
}
