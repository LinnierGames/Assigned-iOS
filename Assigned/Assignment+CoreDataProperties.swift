//
//  Assignments+CoreDataProperties.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/30/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

extension Assignment {
    enum StringKeys {
        static let subtasks = "subtasks"
    }
}

extension Assignment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assignment> {
        return NSFetchRequest<Assignment>(entityName: "Assignments")
    }

    @NSManaged public var deadline: Date?
    
    /** stored in seconds */
    @NSManaged public var durationValue: Double
    @NSManaged public var isCompleted: Bool
    @NSManaged public var priorityValue: Int16
    @NSManaged public var notes: String?
    @NSManaged public var sessions: Set<Session>?
    @NSManaged public var tasks: Set<Task>?

}

// MARK: Generated accessors for sessions
extension Assignment {

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: Session)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: Session)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

}

// MARK: Generated accessors for tasks
extension Assignment {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
