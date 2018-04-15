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
        
        if let parentVcEventHandler = self.parent as? UIViewController & EKEventEditViewDelegate {
            var dateComponent = DateComponents(date: self.selectedDate, forComponents: DateComponents.AllComponents)
            dateComponent.hour = hour
            let tappedHourDate = dateComponent.date!
            
            self.calendar.presentNewEvent(for: tappedHourDate, in: parentVcEventHandler)
        } else {
            debugPrint("self.parent vc is not EKEventEditViewDelegate \(String(describing: self.parent))")
        }
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

extension DayViewController {
    var eventWidth: CGFloat {
        // references TimelineView.draw(..)
        return self.view.bounds.size.width - 53
    }
    
    var dayHeaderView: CalendarKit.DayHeaderView {
        return self.dayView.subviews[1] as! CalendarKit.DayHeaderView
    }
    
    var timelineContainers: [CalendarKit.TimelineContainer] {
        let timelinePagerView = self.dayView.subviews[0] as! CalendarKit.TimelinePagerView
        let pagingScrollView = timelinePagerView.subviews[0] as! UIScrollView // PagingScrollView
        let timelines = pagingScrollView.subviews as! [TimelineContainer]
        
        return timelines
    }
    
    var timelineContainer: CalendarKit.TimelineContainer {
        return self.timelineContainers[1]
    }
}

extension TimelineContainer {
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - parameter point: must be in the cartesian plate of the timeline view
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    func hour(for point: CGPoint) -> Int {
        //let timelineView = self.timeline
        //let viewHeight = timelineView.fullHeight
        
        return Int(timeFloat(for: point))
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - parameter point: must be in the cartesian plate of the timeline view
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    func date(for point: CGPoint, with offsettingDate: Date) -> Date {
        var timeFloatValue = timeFloat(for: point)
        let hourValue = Int(timeFloatValue)
        
        timeFloatValue -= CGFloat(hourValue)
        
        timeFloatValue -= 0.22
        
        let minuteValue: Int = {
            if timeFloatValue >= 0.75 {
                return 45
            } else if timeFloatValue >= 0.5 {
                return 30
            } else if timeFloatValue >= 0.25 {
                return 15
            } else {
                return 0
            }
        }()
        
        var dateComponents = offsettingDate.components(DateComponents.DayComponents.union(DateComponents.TimeComponents))
        dateComponents.hour = hourValue
        dateComponents.minute = minuteValue
        
        guard let date = Calendar.current.date(from: dateComponents)
            else {
            fatalError("cannot make date with date components")
        }
        
        return date
    }
    
    private func timeFloat(for point: CGPoint) -> CGFloat {
        let cellHeightForAn_Hour: CGFloat = 45.0
        
        return max(0, point.y / cellHeightForAn_Hour)
    }
}


extension CalendarDayViewController: CalendarStackDelegate {
    func calendar(stack: CalendarStack, eventStoreDidChange eventStore: EKEventStore) {
        self.reloadData()
    }
}
