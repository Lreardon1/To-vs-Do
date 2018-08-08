//
//  CompletedToDoListTableViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/26/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit

class CompletedToDoListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var completedToDoList = [CompletedToDoItem]() {
        didSet {
            completedToDoTableView.reloadData()
        }
    }
    @IBOutlet weak var completedToDoTableView: UITableView!
    @IBOutlet weak var deleteAllButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completedToDoList = CoreDataHelper.retrieveCompletedToDoItem()
        completedToDoList.sort { (toDoOne, toDoTwo) -> Bool in
            toDoOne.dateCompleted! > toDoTwo.dateCompleted!
        }
        
        
        if(completedToDoList.count > 50) {
            for i in 0...(completedToDoList.count - 50) {
                let toDoDelete = self.completedToDoList[i]
                CoreDataHelper.deleteCompletedToDoItem(toDoItem: toDoDelete)
            }
            self.completedToDoList = CoreDataHelper.retrieveCompletedToDoItem()
            self.completedToDoTableView.reloadData()
            StatCalculatorService.calculateStats()
        }
        completedToDoTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        completedToDoList = CoreDataHelper.retrieveCompletedToDoItem()
        completedToDoList.sort { (toDoOne, toDoTwo) -> Bool in
            toDoOne.dateCompleted! > toDoTwo.dateCompleted!
        }
        completedToDoTableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return completedToDoList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "completedToDoListTableViewCell", for: indexPath) as! CompletedToDoListTableViewCell
        
        let toDoItem = completedToDoList[indexPath.row]
        cell.completedToDoTitleLabel.text = toDoItem.title
        cell.completedToDoTimeLabel.text = "Completed on: " + String((toDoItem.dateCompleted?.convertToString())!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Mark as Incomplete") { (action, indexPath) in
            let toDoIncomplete = self.completedToDoList[indexPath.row]
            let newToDo = CoreDataHelper.newToDoItem()
            newToDo.title = toDoIncomplete.title
            newToDo.dueDate = toDoIncomplete.dueDate
            
            CoreDataHelper.saveNewToDoItem()
            StatCalculatorService.calculateStats()
            CoreDataHelper.deleteCompletedToDoItem(toDoItem: toDoIncomplete)
            self.completedToDoList = CoreDataHelper.retrieveCompletedToDoItem()
            self.completedToDoList.sort { (toDoOne, toDoTwo) -> Bool in
                toDoOne.dateCompleted! > toDoTwo.dateCompleted!
            }
            self.completedToDoTableView.reloadData()
            StatCalculatorService.calculateStats()
        }
        delete.backgroundColor = #colorLiteral(red: 0.8862180114, green: 0.1252332032, blue: 0, alpha: 1)
        
        return [delete]
    }
    
}
