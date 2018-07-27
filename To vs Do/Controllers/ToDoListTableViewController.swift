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
        cell.toDoItemTimeLabel.text = "Due: " + String((toDoItem.dueDate?.convertToString().prefix(6))!)
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
        }
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            let toDoDelete = self.toDoList[indexPath.row]
            CoreDataHelper.deleteToDoItem(toDoItem: toDoDelete)
            self.toDoList = CoreDataHelper.retrieveToDoItem()
            self.toDoTableView.reloadData()
        }
        
        save.backgroundColor = UIColor.green
        delete.backgroundColor = UIColor.red
        
        return [save, delete]
    }
    
//    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
//        let initialViewController = UIStoryboard.initialViewController(for: .login)
//        self.view.window?.rootViewController = initialViewController
//        self.view.window?.makeKeyAndVisible()
//    }
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        
    }
}
