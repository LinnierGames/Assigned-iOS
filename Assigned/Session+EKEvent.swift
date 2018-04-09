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
        let taskTitle = self.task.title
        
        // Event title has default session title, which is the task title
        if event.title == taskTitle {
            self.clearTitle()
        } else {
            self.title = event.title
        }
        
        // Dates
        self.startDate = event.startDate
        self.endDate = event.endDate
    }
    
    /**
     Updates the "linked" calendar event
     
     - precondition: the session must already have a calendar event assigned to its id
     before saving on any context
     */
    public override func willSave() {
        super.willSave()
        
        guard self.isDeleted == false else { return }
        
        let calendar = try! CalendarStack(delegate: nil) //MUST GUARD TO NOT ALLOW THE USER TO SAVE A SESSION WITHOUT PRIVACY ACCESS
        guard let sessionEvent = calendar.event(for: self) else {
            fatalError("the session must already have a calendar event assigned to its id before saving")
        }
        
        // update and save the event
        sessionEvent.setValuesFor(session: self)
        calendar.save(event: sessionEvent)
        
        if self.eventLastModifiedDate != sessionEvent.lastModifiedDate {
            self.eventLastModifiedDate = sessionEvent.lastModifiedDate!
        }
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
