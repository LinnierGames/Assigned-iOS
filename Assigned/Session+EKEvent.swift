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
        if true {
            self.setValuesFor(event: event)
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
}

extension EKEvent {
    func setValuesFor(session: Session) {
        self.title = session.title
        self.startDate = session.startDate
        self.endDate = session.endDate
    }
}
