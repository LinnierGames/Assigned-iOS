//
//  TableViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CalendarKit

class SingleDayViewController: DayViewController {
    
    private lazy var calendar: CalendarStack = {
        do {
            return try CalendarStack()
        } catch let err {
            fatalError(err.localizedDescription)
        }
    }()
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        return calendar.events(for: date).map(CalendarKit.Event.init)
    }
    
    // MARK: DayViewDelegate
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
    }
    
    override func dayViewDidLongPressTimelineAtHour(_ hour: Int) {
    }
    
    override func dayView(dayView: DayView, willMoveTo date: Date) {
    }
    
    override func dayView(dayView: DayView, didMoveTo date: Date) {
    }

}
