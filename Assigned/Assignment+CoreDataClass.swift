//
//  Task+CoreDataClass.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Assignment)
public class Assignment: DirectoryInfo {
    
    enum Priorities: Int, Equatable, CustomStringConvertible {
        case None = 0
        case Low
        case Medium
        case High
        
        var description: String {
            switch self {
            case .None:
                return ""
            case .Low:
                return "Low"
            case .Medium:
                return "Medium"
            case .High:
                return "High"
            }
        }
    }
    
    /** public interface of the task priority */
    var priority: Priorities {
        set {
            self.priorityValue = Int16(newValue.rawValue)
        }
        
        get {
            guard let priority = Priorities(rawValue: Int(self.priorityValue)) else {
                fatalError("could not convert into an enum from database")
            }
            
            return priority
        }
    }
    
    convenience init(title: String, effort: Float,
                     deadline: Date? = nil,
                     priority: Assignment.Priorities = .None,
                     notes: String = "",
                     isCompleted: Bool = false,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.title = title
        self.effort = effort
        self.deadline = deadline
        self.priorityValue = Int16(priority.rawValue)
        self.notes = notes
        self.isCompleted = isCompleted
    }

}

extension NSFetchedResultsController {
    @objc func assignment(at indexPath: IndexPath) -> Assignment {
        return self.object(at: indexPath) as! Assignment
    }
}
