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

@objc(Task)
public class Task: DirectoryInfo {
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required public init(title: String, parent: Directory?, in context: NSManagedObjectContext) {
        super.init(title: title, parent: parent, in: context)
        
        // Self's default values
        self.duration = 0.0
        self.deadline = nil
        self.priority = .None
        self.notes = nil
        self.isCompleted = false
    }
    
    init(title: String, effort: Float,
                     deadline: Date? = nil,
                     priority: Task.Priorities = .None,
                     notes: String = "",
                     isCompleted: Bool = false,
                     parent directory: Directory?,
                     in context: NSManagedObjectContext) {
        
        super.init(title: title, parent: directory, in: context)
        
        self.duration = effort
        self.deadline = deadline
        self.priorityValue = Int16(priority.rawValue)
        self.notes = notes
        self.isCompleted = isCompleted
    }
    
    public override func copying() -> Task {
        let copiedTask = super.copying() as! Task
        
        // Copy self's properties to copied
        copiedTask.deadline = self.deadline
        copiedTask.durationValue = self.durationValue
        copiedTask.isCompleted = self.isCompleted
        copiedTask.priorityValue = self.priorityValue
        copiedTask.notes = self.notes
        
        if let selfSessions = self.sessions {
            for aSession in selfSessions {
                let copiedSession = aSession.copying()
                copiedTask.addToSessions(copiedSession)
            }
        }
        
        if let selfSubtasks = self.subtasks {
            for aSubtask in selfSubtasks {
                let copiedSubtask = aSubtask.copying()
                copiedTask.addToSubtasks(copiedSubtask)
            }
        }
        
        return copiedTask
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
        if let sessions = self.sessions {
            return sessions.reduce(0, { $0 + $1.completedDuration })
        } else {
            return 0
        }
    }
    
    /** number of seconds of planned sessions in the future of today's time */
    var plannedDurationOfSessions: TimeInterval {
        if let sessions = self.sessions {
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
        return "Task"
    }
}

extension Directory {
    var task: Task {
        return self.info as! Task
    }
    
    var isTask: Bool {
        return self.info is Task
    }
}

extension NSFetchedResultsController {
    @objc func task(at indexPath: IndexPath) -> Task {
        return self.object(at: indexPath) as! Task
    }
}
