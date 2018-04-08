//
//  RTEvent.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//  A map between CalendarKit.Event and a EventKit.EKEvent
//

import Foundation
import EventKit
import CalendarKit

class AAEvent: CalendarKit.Event {
    var eventData: EKEvent
    
    init(event: EKEvent) {
        self.eventData = event
        
        super.init()
        
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.text = event.title
        self.attributedText = nil
        self.color = UIColor(cgColor: event.calendar.cgColor)
        self.backgroundColor = self.color.withAlphaComponent(0.3)
        self.textColor = UIColor.black
        self.font = UIFont.boldSystemFont(ofSize: 12)
        self.userInfo = nil
    }
}
