//
//  NewToDoItemViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/25/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewToDoItemViewController: UIViewController {
    
    @IBOutlet weak var toDoTitleTextField: UITextField!
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var toDoDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toDoDatePicker.minimumDate = Date()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "addItem":
            let destination = segue.destination as! ToDoListTableViewController
            destination.toDoList = CoreDataHelper.retrieveToDoItem()
            destination.toDoList.sort { (toDoOne, toDoTwo) -> Bool in
                toDoOne.dueDate! < toDoTwo.dueDate!
            }
        default:
            print("unexpected segue identifier")
        }
    }
    
    @IBAction func addItemButtonPressed(_ sender: UIButton) {
        
        if(toDoTitleTextField.text != "") {
            let newToDo = CoreDataHelper.newToDoItem()
            newToDo.title = toDoTitleTextField.text
            newToDo.dueDate = toDoDatePicker.date
            
            CoreDataHelper.saveNewToDoItem()
            StatCalculatorService.calculateStats()
        }
    }
}
