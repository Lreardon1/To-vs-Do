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
            toDoOne.dateCompleted! < toDoTwo.dateCompleted!
        }
        completedToDoTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        completedToDoList = CoreDataHelper.retrieveCompletedToDoItem()
        completedToDoList.sort { (toDoOne, toDoTwo) -> Bool in
            toDoOne.dateCompleted! < toDoTwo.dateCompleted!
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
        if(toDoItem.dueDate! > toDoItem.dateCompleted! || (toDoItem.dateCompleted?.convertToString().contains(String((toDoItem.dueDate?.convertToString().prefix(6))!)))!) {
            cell.completedToDoTimeLabel.text = "Completed on: " + String((toDoItem.dateCompleted?.convertToString().prefix(6))!) + ", on time!"
        } else {
            cell.completedToDoTimeLabel.text = "Completed on: " + String((toDoItem.dateCompleted?.convertToString().prefix(6))!) + ", a bit behind"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            let toDoDelete = self.completedToDoList[indexPath.row]
            CoreDataHelper.deleteCompletedToDoItem(toDoItem: toDoDelete)
            self.completedToDoList = CoreDataHelper.retrieveCompletedToDoItem()
            self.completedToDoTableView.reloadData()
        }
        delete.backgroundColor = UIColor.red
        
        return [delete]
    }
    
    @IBAction func deleteAllButtonTapped(_ sender: UIBarButtonItem) {
        for item in completedToDoList {
            CoreDataHelper.deleteCompletedToDoItem(toDoItem: item)
        }
        completedToDoList = CoreDataHelper.retrieveCompletedToDoItem()
        completedToDoTableView.reloadData()
    }
    
}
