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
        set (newEndDate) {
            let sinceStartDate = newEndDate.timeIntervalSince(self.startDate)
            
            self.durationValue = sinceStartDate
        }
        get {
            return self.startDate.addingTimeInterval(self.durationValue)
        }
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
    
    public override func awakeFromFetch() {
        super.awakeFromFetch()
        
        //TODO: create shared calendar store?
        let calendar = try! CalendarStack() //MUST GUARD TO NOT ALLOW THE USER TO SAVE A SESSION WITHOUT PRIVACY ACCESS
        
        // find the session's event and update self by the found event
        if let sessionEvent = calendar.event(for: self) {
            self.setValuesFor(event: sessionEvent)
            
            // iCal event was not found: delete self
        } else {
            guard let context = self.managedObjectContext else {
                fatalError("no context after fetching")
            }
            
            // delete and save the context
            context.delete(self)
            //FIXME: don't save context here, may have side-effects to other changes on the same context
            PersistenceStack().saveContext(context: context)
        }
    }
    
    /**
     Updates the "linked" calendar event
     
     - precondition: the session must already have a calendar event assigned to its id
     before saving on any context
     */
    public override func didSave() {
        super.didSave()
        
        guard self.isDeleted == false else { return }
        
        let calendar = try! CalendarStack() //MUST GUARD TO NOT ALLOW THE USER TO SAVE A SESSION WITHOUT PRIVACY ACCESS
        guard let sessionEvent = calendar.event(for: self) else {
            fatalError("the session must already have a calendar event assigned to its id before saving")
        }
        
        // update and save the event
        sessionEvent.setValuesFor(session: self)
        calendar.save(event: sessionEvent)
    }
    
    /**
     Deletes the "linked" calendar event
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        
        let calendar = try! CalendarStack() //MUST GUARD TO NOT ALLOW THE USER TO SAVE A SESSION WITHOUT PRIVACY ACCESS
        if let sessionEvent = calendar.event(for: self) {
            
            // delete the event
            calendar.delete(event: sessionEvent)
        } else {
            print("no event was found to delete when deleting the session")
        }
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}

extension NSFetchedResultsController {
    @objc func session(at indexPath: IndexPath) -> Session {
        return self.object(at: indexPath) as! Session
    }
}
