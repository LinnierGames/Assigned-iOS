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

@objc protocol CalendarDayViewControllerDelegate: class, EKEventViewDelegate, EKEventEditViewDelegate {
    @objc optional func planner(controller: CalendarDayViewController, didChangeTo date: Date)
}

class CalendarDayViewController: DayViewController {
    
    private lazy var calendar: CalendarStack = {
        do {
            return try CalendarStack(delegate: self)
        } catch let err {
            fatalError(err.localizedDescription)
        }
    }()
    
    private(set) var events: [EKEvent] = []
    
    @IBOutlet weak var calendarDelegate: (CalendarDayViewControllerDelegate & UIViewController)?
    
    var selectedDate: Date {
        set {
            self.dayView.state!.move(to: newValue)
        }
        get {
            return self.dayView.state!.selectedDate
        }
    }
    
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
            calendar.present(event: event.eventData, in: delegate)
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
    
//    override func dayView(dayView: DayView, willMoveTo date: Date) {
//
//    }
    
    override func dayView(dayView: DayView, didMoveTo date: Date) {
//        self.selectedDate = date
        self.calendarDelegate?.planner?(controller: self, didChangeTo: date)
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: scroll to today's time
        dayView.autoScrollToFirstEvent = true
//        dayView.timelinePagerView.timelinePager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PrivacyService.Calendar.authorize(successfulHandler: { [unowned self] in
            self.reloadData()
        })
    }
    
    //TODO: hide the task panel when scroll near the bottom
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let yOffset = scrollView.contentOffset.y
//        let scrollHeight = scrollView.contentSize.height
//        let scrollFrameHeight = scrollView.frame.height
//
//        if yOffset < scrollHeight - scrollFrameHeight {
//            //            self.calendarDelegate?.
//        }
//    }
}

extension CalendarDayViewController: CalendarStackDelegate {
    func calendar(stack: CalendarStack, eventStoreDidChange eventStore: EKEventStore) {
        self.reloadData()
    }
}
