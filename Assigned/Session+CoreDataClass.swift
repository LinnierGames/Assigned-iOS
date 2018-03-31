//
//  Session+CoreDataClass.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Session)
public class Session: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Sessions")
    }
    
    /** stored as seconds */
    @NSManaged public var durationValue: TimeInterval
    
    /** represented in hours (e.g. 3,600 seconds is 1.0 hours) */
    public var duration: Double {
        set {
            self.durationValue = newValue * CTDateComponentHour
        }
        get {
            return self.durationValue / CTDateComponentHour
        }
    }
    
    @NSManaged public var name: String
    @NSManaged public var startDate: Date
    @NSManaged public var assignment: Assignment
    
    convenience init(name: String,
                     startDate: Date,
                     duration: TimeInterval = 1,
                     assignment: Assignment,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.name = name
        self.startDate = startDate
        self.duration = duration
        
        self.assignment = assignment
    }
    
    var dayOfStartDate: Date {
        return startDate.midnight
    }
    
    enum StringProperties {
        static let dayOfStartDate = "dayOfStartDate"
    }
}

extension NSFetchedResultsController {
    @objc func session(at indexPath: IndexPath) -> Session {
        return self.object(at: indexPath) as! Session
    }
}
