//
//  Session+CoreDataProperties.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/31/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

extension Session {
    enum StringKeys {
        static let task = "task"
        static let dayOfStartDate = "dayOfStartDate"
    }
}

extension Session {
    
    /** <#Lorem ipsum dolor sit amet.#> */
    var dayOfStartDate: Date {
        return self.startDate.midnight
    }
}

extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Sessions")
    }

//    @NSManaged public var dayOfStartDate: NSDate?
    
    /** stored as seconds */
    @NSManaged public var durationValue: Double
    @NSManaged public var startDate: Date
    @NSManaged public var titleValue: String?
    @NSManaged public var task: Task
    @NSManaged public var eventIdentifier: String!
    @NSManaged public var eventLastModifiedDate: Date?

}
