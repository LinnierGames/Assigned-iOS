//
//  Tasks+CoreDataProperties.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/30/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

extension Task {
    enum StringKeys {
        static let durationValue = "durationValue"
        static let deadline = "deadline"
        static let isCompleted = "isCompleted"
        static let priorityValue = "priorityValue"
        static let notes = "notes"
        static let subtasks = "subtasks"
    }
}

extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Tasks")
    }

    @NSManaged public var deadline: Date?
    
    /** stored in seconds */
    @NSManaged public var durationValue: Double
    @NSManaged public var isCompleted: Bool
    @NSManaged public var priorityValue: Int16
    @NSManaged public var notes: String?
    @NSManaged public var sessions: Set<Session>?
    @NSManaged public var subtasks: Set<Subtask>?

}

// MARK: Generated accessors for sessions
extension Task {

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: Session)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: Session)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

}

// MARK: Generated accessors for subtasks
extension Task {

    @objc(addSubtasksObject:)
    @NSManaged public func addToSubtasks(_ value: Subtask)

    @objc(removeSubtasksObject:)
    @NSManaged public func removeFromSubtasks(_ value: Subtask)

    @objc(addSubtasks:)
    @NSManaged public func addToSubtasks(_ values: NSSet)

    @objc(removeSubtasks:)
    @NSManaged public func removeFromSubtasks(_ values: NSSet)

}
