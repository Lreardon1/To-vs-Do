//
//  NewToDoItemViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/25/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import FirebaseDatabase
import UserNotifications

class NewToDoItemViewController: UIViewController, UITextFieldDelegate {
    
//    let i: UILabel = {
//        let label = UILabel()
//        label.text = "yer"
//
//       return label
//    }()
    
    @IBOutlet weak var toDoTitleTextField: UITextField!
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var toDoDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toDoTitleTextField.delegate = self
        
        toDoDatePicker.minimumDate = Date()
        super.viewDidLoad()
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        self.toDoTitleTextField.inputAccessoryView = toolbar
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let text = textField.text else { return true }
//        let newLength = text.count + string.count - range.length
//        return newLength <= limitLength
//    }
    
    @objc func doneButtonAction() {
        toDoTitleTextField.endEditing(true)
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
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = toDoTitleTextField.text!
            notificationContent.sound = UNNotificationSound.default()
            
            let triggerDate = toDoDatePicker.date
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            
            let notificationRequest = UNNotificationRequest(identifier: toDoTitleTextField.text! + toDoDatePicker.date.convertToString(), content: notificationContent, trigger: trigger)
            UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { error in
                if error != nil {
                    print("something went wrong")
                } else {
                }
            })
            let newToDo = CoreDataHelper.newToDoItem()
            newToDo.title = toDoTitleTextField.text
            newToDo.dueDate = toDoDatePicker.date
            
            CoreDataHelper.saveNewToDoItem()
            StatCalculatorService.calculateStats()
        }
    }
}
