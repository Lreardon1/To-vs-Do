//
//  StatCalculatorService.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/30/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import CoreData
import FirebaseDatabase

struct StatCalculatorService {
    
    public static func calculateStats() {
        let toDoList = CoreDataHelper.retrieveToDoItem()
        let completed = CoreDataHelper.retrieveCompletedToDoItem()
        let currentDate = Date()
        var toDoToday = 0
        var completedToday = 0
        var totalCompleted = 0.0
        
        for item in toDoList {
            if(item.dueDate?.convertToString().contains(currentDate.convertToString().prefix(6)))! {
                toDoToday += 1
            }
        }
        for item in completed {
            if(item.dateCompleted?.convertToString().contains(currentDate.convertToString().prefix(6)))! {
                completedToday += 1
            }
            if(item.dueDate?.convertToString().contains(currentDate.convertToString().prefix(6)))! {
                toDoToday += 1
            }
            totalCompleted += 1
        }
        
        let timeInterval = Date().timeIntervalSince(findMinDate())
        let timeIntervalInDays = timeInterval/86400
        let average = totalCompleted/timeIntervalInDays
        
        let toDoRef = Database.database().reference().child("stats").child(User.current.uid).child("toDoToday")
        let completedRef = Database.database().reference().child("stats").child(User.current.uid).child("completedToday")
        let averageRef = Database.database().reference().child("stats").child(User.current.uid).child("dailyAverage")
        
        toDoRef.setValue(toDoToday)
        completedRef.setValue(completedToday)
        averageRef.setValue(average)
        
    }
    
    static func findMinDate() -> Date{
        var minDate = Date()
        for item in CoreDataHelper.retrieveCompletedToDoItem() {
            if(item.dateCompleted! < minDate) {
                minDate = item.dateCompleted!
            }
        }
        return minDate
    }
}
