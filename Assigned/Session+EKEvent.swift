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
    
    public override func awakeFromFetch() {
        super.awakeFromFetch()
        
        //TODO: update from any changes from ical
    }
    
    /**
     Updates the "linked" calendar event
     
     - precondition: the session must already have a calendar event assigned to its id
     before saving on any context
     */
    public override func didSave() {
        super.didSave()
        
        let calendar = try! CalendarStack() //MUST GUARD TO NOT ALLOW THE USER TO SAVE A SESSION WITHOUT PRIVACY ACCESS
        guard let sessionEvent = calendar.event(for: self) else {
            fatalError("the session must already have a calendar event assigned to its id before saving")
        }
        
        // update and save the event
        sessionEvent.setValuesFor(session: self)
        calendar.save(event: sessionEvent)
    }
}

extension EKEvent {
    func setValuesFor(session: Session) {
        self.title = session.title
        self.startDate = session.startDate
        self.endDate = session.endDate
    }
}
