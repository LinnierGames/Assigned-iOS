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
        static let startDate = "startDate"
        static let durationValue = "durationValue"
        static let titleValue = "titleValue"
        static let eventIdentifier = "eventIdentifier"
        static let eventLastModifiedDate = "eventLastModifiedDate"
        
        static let dayOfStartDate = "dayOfStartDate"
    }
}

extension Session {
    
    @objc dynamic var dayOfStartDate: Date {
        return self.startDate.midnight
    }
    
    /** <#Lorem ipsum dolor sit amet.#> */
//    var dayOfStartDate: Date {
//
//        self.willAccessValue(forKey: "dayOfStartDate")
//        var dayValue = self.primitiveValue(forKey: "dayOfStartDate") as! Date?
//        self.didAccessValue(forKey: "dayOfStartDate")
//
//        if dayValue == nil {
//            let midnight = self.startDate.midnight
//
//            dayValue = midnight
//            self.setPrimitiveValue(midnight, forKey: "dayOfStartDate")
//        }
//
//        return dayValue!
//    }
    
//    public override func willAccessValue(forKey key: String?) {
//        super.willAccessValue(forKey: key)
//
//        if let key = key {
//            switch key {
//            case "dayOfStartDate":
//                self.dayOfStartDate = self.startDate.midnight
//            default:
//                break
//            }
//        }
//    }
}

extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Sessions")
    }

//    @NSManaged public var dayOfStartDate: Date!
    
    /** stored as seconds */
    @NSManaged public var durationValue: Double
    @NSManaged public var startDate: Date
    @NSManaged public var titleValue: String?
    @NSManaged public var task: Task
    @NSManaged public var eventIdentifier: String!
    @NSManaged public var eventLastModifiedDate: Date?

}
