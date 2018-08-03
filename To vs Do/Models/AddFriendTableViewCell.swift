//
//  FriendTableViewCell.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/31/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit

protocol AddFriendsTableViewCellDelegate: class {
    func didTapAddFriendButton(_ followButton: UIButton, on cell: AddFriendTableViewCell)
}

class AddFriendTableViewCell: UITableViewCell {
    
    weak var delegate: AddFriendsTableViewCellDelegate?
    
    @IBOutlet weak var addFriendProfileImageView: UIImageView!
    
    @IBOutlet weak var addFriendUsernameLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBAction func addFriendButtonTapped(_ sender: UIButton) {
        delegate?.didTapAddFriendButton(sender, on: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addFriendButton.layer.borderColor = UIColor.lightGray.cgColor
        addFriendButton.layer.borderWidth = 1
        addFriendButton.layer.cornerRadius = 6
        addFriendButton.clipsToBounds = true
        
        addFriendButton.setTitle("Add", for: .normal)
        addFriendButton.setTitle("Requested", for: .selected)
    }
    
    
}
