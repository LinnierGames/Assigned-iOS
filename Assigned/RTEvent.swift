//
//  RTEvent.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import EventKit
import CalendarKit

extension CalendarKit.Event {
    convenience init(event: EKEvent) {
        self.init()
        
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
