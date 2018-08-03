//
//  AcceptFriendCell.swift
//  To vs Do
//
//  Created by Leith Reardon on 8/2/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit

protocol AcceptFriendCellDelegate: class {
    func didTapAcceptFriendButton(_ acceptButton: UIButton, on cell: AcceptFriendCell)
    func didTapDeclineFriendButton(_ declineButton: UIButton, on cell: AcceptFriendCell)
}

class AcceptFriendCell: UITableViewCell {
    
    weak var delegate: AcceptFriendCellDelegate?
    
    @IBOutlet weak var acceptFriendImage: UIImageView!
    @IBOutlet weak var acceptFriendUsername: UILabel!
    @IBOutlet weak var acceptFriendButton: UIButton!
    @IBOutlet weak var decineFriendButton: UIButton!
    
    @IBAction func acceptFriendButtonTapped(_ sender: UIButton) {
        delegate?.didTapAcceptFriendButton(sender, on: self)
    }
    
    @IBAction func declineFriendButtonTapped(_ sender: UIButton) {
        delegate?.didTapDeclineFriendButton(sender, on: self)
    }
}
