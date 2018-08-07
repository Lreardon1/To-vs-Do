//
//  FriendRequestViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 8/2/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import FirebaseDatabase
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

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Report as Inappropriate") { (action, indexPath) in
            let alertController = UIAlertController(title: nil, message: "Are you sure you want to report this user for inapporpiate content?", preferredStyle: .alert)

            let reportAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
                let flaggedUser = self.users[indexPath.row]
                let flaggedUserRef = Database.database().reference().child("flaggedUsers").child(flaggedUser.uid)
                let flaggedDict = ["image_url": flaggedUser.profilePic,
                                   "username": flaggedUser.username,
                                   "reporter_uids/\(User.current.uid)": true] as [String: Any]
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

            let reportAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
                let blockedUser = self.users[indexPath.row]
                let blockedUserRef = Database.database().reference().child("blockedUsers").child(User.current.uid)
                let blockedDict = [blockedUser.uid: true]

                blockedUserRef.updateChildValues(blockedDict)

                let followee = self.users[indexPath.row]

                FriendsService.sendRequest(false, fromCurrentUserTo: followee) { (success) in
                    guard success else { return }

                    followee.isFriend = !followee.isFriend
                }
                UserService.requestedFriends { [unowned self] (users) in
                    self.users = users

                    DispatchQueue.main.async {
                        self.friendRequestTableView.reloadData()
                    }
                }
            })
            alertController.addAction(reportAction)

            let declineAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alertController.addAction(declineAction)
            self.present(alertController, animated: true, completion: nil)
        }

        delete.backgroundColor = #colorLiteral(red: 0.897116363, green: 0.1273201406, blue: 0, alpha: 1)
        block.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        return [delete, block]
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
        }
        UserService.requestedFriends { [unowned self] (users) in
            self.users = users

            DispatchQueue.main.async {
                self.friendRequestTableView.reloadData()
            }
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
        }
        UserService.requestedFriends { [unowned self] (users) in
            self.users = users

            DispatchQueue.main.async {
                self.friendRequestTableView.reloadData()
            }
        }
    }
}
