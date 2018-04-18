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
     Updates properties only if the event's and session's have `lastModifiedDate`
     out of sync
     
     - parameter event: update the reciever's properties with this event
     */
    func setValuesIfNeededFor(event: EKEvent) {
        
        if event.lastModifiedDate! != self.eventLastModifiedDate {
            self.setValuesFor(event: event)
            self.eventLastModifiedDate = event.lastModifiedDate!
        }
    }
    
    /**
     Updates the reciever's properties. Use `setValuesIfNeededFor(..)` to only update
     if `lastModifiedDate`s are not the same
     
     - parameter event: update the reciever's properties with this event
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
     Deletes the "linked" calendar event, if the event still exists
     */
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        
        let calendar = try! CalendarStack(delegate: nil) //MUST GUARD TO NOT ALLOW THE USER TO SAVE A SESSION WITHOUT PRIVACY ACCESS
        if let sessionEvent = calendar.event(for: self) {
            
            // delete the event
            calendar.delete(event: sessionEvent)
        } else {
            debugPrint("no event was found to delete when deleting the session")
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
