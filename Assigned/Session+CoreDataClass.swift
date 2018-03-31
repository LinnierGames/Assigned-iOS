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
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    public var title: String {
        set {
            self.titleValue = newValue
        }
        get {
            if let sessionTitle = self.titleValue {
                return sessionTitle
            } else {
                return self.assignment.title
            }
        }
    }
    
    func clearTitle() {
        self.titleValue = nil
    }
    
    /** represented in hours (e.g. 3,600 seconds is 1.0 hours) */
    public var duration: Double {
        set {
            self.durationValue = newValue * CTDateComponentHour
        }
        get {
            return self.durationValue / CTDateComponentHour
        }
    }
        
    convenience init(title: String?,
                     startDate: Date,
                     duration: TimeInterval = 1,
                     assignment: Assignment,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.titleValue = title
        self.startDate = startDate
        self.duration = duration
        
        self.assignment = assignment
    }
}

extension NSFetchedResultsController {
    @objc func session(at indexPath: IndexPath) -> Session {
        return self.object(at: indexPath) as! Session
    }
}
