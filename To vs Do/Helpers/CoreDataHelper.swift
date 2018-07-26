//
//  CoreDataHelper.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/25/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct CoreDataHelper {
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError()}
        
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        
        return context
    }()
    
    static func newToDoItem() -> ToDo {
        let toDoItem = NSEntityDescription.insertNewObject(forEntityName: "ToDo", into: context) as! ToDo
        return toDoItem
    }
    
    static func newCompletedToDoItem() -> CompletedToDoItem {
        let toDoItem = NSEntityDescription.insertNewObject(forEntityName: "CompletedToDoItem", into: context) as! CompletedToDoItem
        return toDoItem
    }
    
    static func saveNewToDoItem() {
        do {
            try context.save()
        } catch let error {
            print("Could not save \(error.localizedDescription)")
        }
    }
    
    static func saveCompletedToDoItem() {
        do {
            try context.save()
        } catch let error {
            print("Could not save \(error.localizedDescription)")
        }
    }
    
    static func deleteToDoItem(toDoItem: ToDo) {
        context.delete(toDoItem)
        saveNewToDoItem()
    }
    
    static func deleteCompletedToDoItem(toDoItem: CompletedToDoItem) {
        context.delete(toDoItem)
        saveCompletedToDoItem()
    }
    
    static func retrieveToDoItem() -> [ToDo] {
        do {
            let fetchRequest = NSFetchRequest<ToDo>(entityName: "ToDo")
            
            let results = try context.fetch(fetchRequest)
            return results
        } catch let error {
            print("Could not fetch \(error.localizedDescription)")
            return []
        }
    }
    
    static func retrieveCompletedToDoItem() -> [CompletedToDoItem] {
        do {
            let fetchRequest = NSFetchRequest<CompletedToDoItem>(entityName: "CompletedToDoItem")
            
            let results = try context.fetch(fetchRequest)
            return results
        } catch let error {
            print("Could not fetch \(error.localizedDescription)")
            return []
        }
    }
}
