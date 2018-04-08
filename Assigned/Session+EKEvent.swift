//
//  Session+EKEvent.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/6/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import EventKit

extension Session {
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    func setValuesIfNeededFor(event: EKEvent) {
        
        //TODO: chech for lastModified on event if update is needed
        if event.lastModifiedDate! != self.eventLastModifiedDate {
            self.setValuesFor(event: event)
            self.eventLastModifiedDate = event.lastModifiedDate!
        }
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    func setValuesFor(event: EKEvent) {
        let assignmentTitle = self.assignment.title
        
        // Event title has default session title, which is the assignment title
        if event.title == assignmentTitle {
            self.clearTitle()
        } else {
            self.title = event.title
        }
        
        // Dates
        self.startDate = event.startDate
        self.endDate = event.endDate
    }
    
    /**
     Updates the session with the "linked" iCal event
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    public override func awakeFromFetch() {
        super.awakeFromFetch()
        //
        //        //TODO: create shared calendar store?
        //        let calendar = try! CalendarStack() //MUST GUARD TO NOT ALLOW THE USER TO SAVE A SESSION WITHOUT PRIVACY ACCESS
        //
        //        // find the session's event and update self by the found event
        //        if let sessionEvent = calendar.event(for: self) {
        //            self.setValuesFor(event: sessionEvent)
        //
        //            // iCal event was not found: delete self
        //        } else {
        //            guard let context = self.managedObjectContext else {
        //                fatalError("no context after fetching")
        //            }
        //
        //            // delete and save the context
        //            context.delete(self)
        //            //FIXME: don't save context here, may have side-effects to other changes on the same context
        //            PersistenceStack().saveContext(context: context)
        //        }
    }
    
    /**
     Updates the "linked" calendar event
     
     - precondition: the session must already have a calendar event assigned to its id
     before saving on any context
     */
    public override func didSave() {
        super.didSave()
        
        guard self.isDeleted == false else { return }
        
        let calendar = try! CalendarStack(delegate: nil) //MUST GUARD TO NOT ALLOW THE USER TO SAVE A SESSION WITHOUT PRIVACY ACCESS
        guard let sessionEvent = calendar.event(for: self) else {
            fatalError("the session must already have a calendar event assigned to its id before saving")
        }
        
        // update and save the event
        sessionEvent.setValuesFor(session: self)
        calendar.save(event: sessionEvent)
        
        self.eventLastModifiedDate = sessionEvent.lastModifiedDate!
    }
    
    /**
     Deletes the "linked" calendar event
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        
        let calendar = try! CalendarStack(delegate: nil) //MUST GUARD TO NOT ALLOW THE USER TO SAVE A SESSION WITHOUT PRIVACY ACCESS
        if let sessionEvent = calendar.event(for: self) {
            
            // delete the event
            calendar.delete(event: sessionEvent)
        } else {
            print("no event was found to delete when deleting the session")
        }
    }
}

extension EKEvent {
    func setValuesFor(session: Session) {
        self.title = session.title
        self.startDate = session.startDate
        self.endDate = session.endDate
    }
}
