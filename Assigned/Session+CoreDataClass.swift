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
    
    @NSManaged public var duration: TimeInterval
    @NSManaged public var name: String?
    @NSManaged public var startDate: Date
    @NSManaged public var assignment: Assignment?
    
    convenience init(name: String,
                     startDate: Date,
                     duration: TimeInterval,
                     assignment: Assignment,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.name = name
        self.startDate = startDate
        self.duration = duration
        
        self.assignment = assignment
    }
    
    var date: Date? {
        return startDate.midnight
    }
}

extension NSFetchedResultsController {
    @objc func session(at indexPath: IndexPath) -> Session {
        return self.object(at: indexPath) as! Session
    }
}
