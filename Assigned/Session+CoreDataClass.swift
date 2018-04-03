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
        
    required public convenience init(title: String?,
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
    
    public func copying() -> Session {
        let copiedSession = type(of: self).init(title: self.title, startDate: self.startDate, duration: self.duration, assignment: self.assignment, in: self.managedObjectContext!)
        
        return copiedSession
    }
    
    // MARK: - RETURN VALUES
    
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
    
    /** addes the duration, in seconds, to the start date to return the end date */
    public var endDate: Date {
        return self.startDate.addingTimeInterval(self.durationValue)
    }
    
    /** true if the session's end date is behind the today's time */
    var isA_CompletedSession: Bool {
        return self.endDate < Date()
    }
    
    /** <#Lorem ipsum dolor sit amet.#> */
    var completedDuration: TimeInterval {
        if isA_CompletedSession {
            return self.durationValue
        } else {
            let todaysDate = Date()
            
            // return how long the session has been in progress since the startDate and today's time
            return max(0, todaysDate.timeIntervalSince(self.startDate))
        }
    }
    
    /** true if the session's start date is ahead of today's time */
    var isA_PlannedSession: Bool {
        return self.startDate > Date()
    }
    
    var plannedDuration: TimeInterval {
        if isA_PlannedSession {
            return self.durationValue
        } else {
            let todaysDate = Date()
            
            // return how long much more is remaining from today's time till the end date
            return max(0, self.endDate.timeIntervalSince(todaysDate))
        }
    }
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}

extension NSFetchedResultsController {
    @objc func session(at indexPath: IndexPath) -> Session {
        return self.object(at: indexPath) as! Session
    }
}
