//
//  Task+CoreDataProperties.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/31/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

extension Task {
    enum StringKeys {
        static let assignment = "assignment"
    }
}

extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Tasks")
    }

    @NSManaged public var isCompleted: Bool
    @NSManaged public var title: String
    @NSManaged public var assignment: Assignment

}
