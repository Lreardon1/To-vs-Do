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
    
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var toDoTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let save = UITableViewRowAction(style: .normal, title: "Mark as Complete") { (action, indexPath) in
            let completedToDo = self.toDoList[indexPath.row]
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
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            let toDoDelete = self.toDoList[indexPath.row]
            CoreDataHelper.deleteToDoItem(toDoItem: toDoDelete)
            self.toDoList = CoreDataHelper.retrieveToDoItem()
            self.toDoTableView.reloadData()
            StatCalculatorService.calculateStats()
        }
        
        save.backgroundColor = #colorLiteral(red: 0.3497066498, green: 0.9791168571, blue: 0.3165050149, alpha: 1)
        delete.backgroundColor = #colorLiteral(red: 0.897116363, green: 0.1273201406, blue: 0, alpha: 1)
        
        return [save, delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
        let initialViewController = UIStoryboard.initialViewController(for: .login)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        
    }
}