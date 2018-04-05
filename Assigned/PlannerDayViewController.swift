//
//  TableViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI

class PlannerDayViewController: DayViewController {
    
    private lazy var calendar: CalendarStack = {
        do {
            return try CalendarStack()
        } catch let err {
            fatalError(err.localizedDescription)
        }
    }()
    
    private(set) var events: [EKEvent] = []
    
    @IBOutlet weak var calendarDelegate: (UIViewController & EKEventViewDelegate & EKEventEditViewDelegate)?
    
    // MARK: - RETURN VALUES
    
    // MARK: EventDataSource
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        guard PrivacyService.Calendar.isAuthorized else {
            return []
        }
        
        self.events = calendar.events(for: date)
        
        return self.events.map(AAEvent.init)
    }
    
    // MARK: - VOID METHODS
    
    // MARK: DayViewDelegate
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let event = eventView.descriptor as! AAEvent? else {
            return
        }
        
        if let delegate = self.calendarDelegate {
            calendar.present(event: event.eventData, for: delegate)
        }
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
    }
    
    override func dayViewDidLongPressTimelineAtHour(_ hour: Int) {
        guard PrivacyService.Calendar.isAuthorized else {
            return //can't add event if not authorized
        }
        
        //TODO: insert event longpressing the timeline
    }
    
    override func dayView(dayView: DayView, willMoveTo date: Date) {
    }
    
    override func dayView(dayView: DayView, didMoveTo date: Date) {
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayView.autoScrollToFirstEvent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PrivacyService.Calendar.authorize(successfulHandler: { [unowned self] in
            self.reloadData()
        })
    }
}
