//
//  ToDoItem.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/25/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import Foundation

class ToDoItem {
    
    let title: String
    let dueDate: Date
    let completionDate: Date?
    
    init(title: String, dueDate: Date, completionDate: Date) {
        self.title = title
        self.dueDate = dueDate
        self.completionDate = completionDate
    }
}
