//
//  ToDoListTableViewCell.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/25/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit


class ToDoListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var toDoItemTitleLabel: UILabel!
    @IBOutlet weak var toDoItemTimeLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        if(checkButton.isSelected == true) {
            checkButton.isSelected = false
            checkButton.setImage(UIImage(named: "UnCheck"), for: UIControlState.normal)
        } else {
            checkButton.isSelected = true
            checkButton.setImage(UIImage(named: "CheckedBox"), for: UIControlState.normal)
        }
        
    }
    
    
}
