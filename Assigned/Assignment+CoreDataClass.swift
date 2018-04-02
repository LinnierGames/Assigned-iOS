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
    
    //TODO: remove "init" helper
    static func createAssignment(title: String, effort: Float,
                                 deadline: Date? = nil,
                                 priority: Assignment.Priorities = .None,
                                 notes: String = "",
                                 isCompleted: Bool = false,
                                 parent directory: Directory? = nil,
                                 in context: NSManagedObjectContext) -> Assignment {
        
        let newAssignment = Assignment(context: context)
        
        newAssignment.title = title
        newAssignment.duration = effort
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
     durationValue is stored in seconds, thus this computed var, effort, will return
     durationValue in hours
     */
    var duration: Float {
        set {
            self.durationValue = TimeInterval(newValue) * CTDateComponentHour
        }
        get {
            return Float(self.durationValue / CTDateComponentHour)
        }
    }
    
    /** number of seconds of completed sessions in the past of today's time */
    var completedDurationOfSessions: TimeInterval {
        if let sessions = self.sessions?.allObjects as! [Session]? {
            return sessions.reduce(0, { $0 + $1.completedDuration })
        } else {
            return 0
        }
    }
    
    /** number of seconds of planned sessions in the future of today's time */
    var plannedDurationOfSessions: TimeInterval {
        if let sessions = self.sessions?.allObjects as! [Session]? {
            return sessions.reduce(0, { $0 + $1.plannedDuration })
        } else {
            return 0
        }
    }
    
    /** number of seconds of unplanned sessions */
    var unplannedDuration: TimeInterval {
        return max(
            0,
            self.durationValue - ( self.completedDurationOfSessions + self.plannedDurationOfSessions )
        )
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
