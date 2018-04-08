//
//  CalendarStack+Session.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/6/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import EventKit

struct SessionCalendarEvent {
    unowned var session: Session
}

extension CalendarStack {
    
    /**
     for the given session, fetches its event with the stored event identifer
     
     - returns: returns nil if no event was found
     */
    func event(for session: Session) -> EKEvent? {
        return eventStore.event(withIdentifier: session.eventIdentifier)
    }
    
    /**
     Creates a new event in iCal for the given session. The sesison's event id
     is also updated with the new event
     
     - parameter session: that will be linked to the new calendar event
     
     - postcondition: events are saved and the storeDidChange will be triggered
     
     - returns: the new calendar event
     */
    @discardableResult
    func createEvent(for session: Session) -> EKEvent {
        
        // create the event and udpate the session's event id
        let newSessionEvent = self.createEvent(with: session.title, startDate: session.startDate, endDate: session.endDate)
        newSessionEvent.setValuesFor(session: session) //updating values that were not updated in the CalendarStack.createEvent(with:, startDate:, endDate:)
        session.eventIdentifier = newSessionEvent.eventIdentifier
        session.eventLastModifiedDate = newSessionEvent.lastModifiedDate
        
        return newSessionEvent
    }
}
