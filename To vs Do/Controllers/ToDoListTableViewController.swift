//
//  ToDoListTableViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/25/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit

class ToDoListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var toDoList = [ToDo]() {
        didSet {
            toDoTableView.reloadData()
        }
    }
    
    var datesArray = [String]()
    var toDoDateDictionary = [String : [ToDo]]()
    
    @IBOutlet weak var toDoTableView: UITableView!
    @IBOutlet weak var markAsCompleteButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        toDoList = CoreDataHelper.retrieveToDoItem()
        toDoList.sort { (toDoOne, toDoTwo) -> Bool in
            toDoOne.dueDate! < toDoTwo.dueDate!
        }
        toDoTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        toDoList = CoreDataHelper.retrieveToDoItem()
        toDoList.sort { (toDoOne, toDoTwo) -> Bool in
            toDoOne.dueDate! < toDoTwo.dueDate!
        }
        toDoTableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toDoList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoListTableViewCell", for: indexPath) as! ToDoListTableViewCell
        
        let toDoItem = toDoList[indexPath.row]
        cell.toDoItemTitleLabel.text = toDoItem.title
        cell.toDoItemTimeLabel.text = "Due: " + String((toDoItem.dueDate?.convertToString())!)
        cell.checkButton.isSelected = false
        cell.checkButton.setImage(UIImage(named: "UnCheck"), for: UIControlState.normal)
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            let toDoDelete = self.toDoList[indexPath.row]
            CoreDataHelper.deleteToDoItem(toDoItem: toDoDelete)
            self.toDoList = CoreDataHelper.retrieveToDoItem()
            self.toDoTableView.reloadData()
            StatCalculatorService.calculateStats()
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.897116363, green: 0.1273201406, blue: 0, alpha: 1)
        
        return [delete]
    }
    
    @IBAction func markAsCompleteButtonTapped(_ sender: UIButton) {
        let cells = self.toDoTableView.visibleCells as! Array<ToDoListTableViewCell>
        
        var count = 0
        
        for cell in cells {
            if (cell.checkButton.isSelected) {
                let completedToDo = self.toDoList[count]
                let newCompletedToDo = CoreDataHelper.newCompletedToDoItem()
                
                newCompletedToDo.title = completedToDo.title
                newCompletedToDo.dueDate = completedToDo.dueDate
                newCompletedToDo.dateCompleted = Date()
                
                CoreDataHelper.saveCompletedToDoItem()
                CoreDataHelper.deleteToDoItem(toDoItem: completedToDo)
                self.toDoList = CoreDataHelper.retrieveToDoItem()
                self.toDoTableView.reloadData()
                StatCalculatorService.calculateStats()
            }
            count += 1
        }
    }
    
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        
    }
}


