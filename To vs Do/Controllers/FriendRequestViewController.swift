//
//  FriendRequestViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 8/2/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator

class FriendRequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var users = [User]()
    
    @IBOutlet weak var friendRequestTableView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserService.requestedFriends { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.friendRequestTableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "acceptFriendCell", for: indexPath) as! AcceptFriendCell
        cell.delegate = self
        configure(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    func configure(cell: AcceptFriendCell, atIndexPath indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        cell.acceptFriendUsername.text = user.username
        cell.acceptFriendImage.af_setImage(withURL: URL(string: user.profilePic)!)
    }
}

extension FriendRequestViewController: AcceptFriendCellDelegate {
    func didTapAcceptFriendButton(_ acceptButton: UIButton, on cell: AcceptFriendCell) {
        guard let indexPath = friendRequestTableView.indexPath(for: cell) else { return }
        
        acceptButton.isUserInteractionEnabled = false
        let followee = users[indexPath.row]
        
        FriendsService.setIsFriend(!followee.isFriend, fromCurrentUserTo: followee) { (success) in
            defer {
                acceptButton.isUserInteractionEnabled = true
            }
            
            guard success else { return }
            
            followee.isFriend = !followee.isFriend
            self.friendRequestTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func didTapDeclineFriendButton(_ declineButton: UIButton, on cell: AcceptFriendCell) {
        guard let indexPath = friendRequestTableView.indexPath(for: cell) else { return }
        
        declineButton.isUserInteractionEnabled = false
        let followee = users[indexPath.row]
        
        FriendsService.sendRequest(false, fromCurrentUserTo: followee) { (success) in
            defer {
                declineButton.isUserInteractionEnabled = true
            }
            
            guard success else { return }
            
            followee.isFriend = !followee.isFriend
            self.friendRequestTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}
