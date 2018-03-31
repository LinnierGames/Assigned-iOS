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
    
    static func createAssignment(title: String, effort: Float,
                                 deadline: Date? = nil,
                                 priority: Assignment.Priorities = .None,
                                 notes: String = "",
                                 isCompleted: Bool = false,
                                 parent directory: Directory? = nil,
                                 in context: NSManagedObjectContext) -> Assignment {
        
        let newAssignment = Assignment(context: context)
        
        newAssignment.title = title
        newAssignment.effort = effort
        newAssignment.deadline = deadline
        newAssignment.priorityValue = Int16(priority.rawValue)
        newAssignment.notes = notes
        newAssignment.isCompleted = isCompleted
        
        _ = Directory.createDirectory(for: newAssignment, parent: directory, in: context)
        
        return newAssignment
    }
    
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
    
    /**
     effortValue is stored in seconds, thus this computed var, effort, will return
     effortValue in hours
     */
    var effort: Float {
        set {
            self.effortValue = TimeInterval(newValue) * CTDateComponentHour
        }
        get {
            return Float(self.effortValue / CTDateComponentHour)
        }
    }
    
    public override var description: String {
        return "Assignment"
    }
}

extension Directory {
    var assignment: Assignment {
        return self.info as! Assignment
    }
    
    var isAssignment: Bool {
        return self.info is Assignment
    }
}

extension NSFetchedResultsController {
    @objc func assignment(at indexPath: IndexPath) -> Assignment {
        return self.object(at: indexPath) as! Assignment
    }
}
