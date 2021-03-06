//
//  Subtask+CoreDataProperties.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/31/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

extension Subtask {
    enum StringKeys {
        static let task = "task"
        static let title = "title"
        static let isCompleted = "isCompleted"
    }
}

extension Subtask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subtask> {
        return NSFetchRequest<Subtask>(entityName: "Subtasks")
    }

    @NSManaged public var isCompleted: Bool
    @NSManaged public var title: String
    @NSManaged public var task: Task

}
