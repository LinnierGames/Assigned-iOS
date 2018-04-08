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
        static let assignment = "assignment"
    }
}

extension Subtask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subtask> {
        return NSFetchRequest<Subtask>(entityName: "Subtasks")
    }

    @NSManaged public var isCompleted: Bool
    @NSManaged public var title: String
    @NSManaged public var assignment: Assignment

}
