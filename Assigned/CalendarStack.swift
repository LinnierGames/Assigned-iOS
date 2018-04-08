//
//  CalendarStack.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import EventKitUI

@objc protocol CalendarStackDelegate {
    @objc optional func calendar(stack: CalendarStack, eventStoreDidChange eventStore: EKEventStore)
    @objc optional func calendar(stack: CalendarStack, didUpdateStaleSessions updatedSessions: Set<Session>)
}

class CalendarStack: NSObject {
    
    //TODO: listen for changes made in the calendar and notify anyone listening
    
    private(set) var eventStore = EKEventStore()
    
    var calendars: [EKCalendar]
    
    weak var delegate: CalendarStackDelegate?
    
    enum CalendarStackErrors: Error {
        case PrivacyRestricted
        
        var localizedDescription: String {
            switch self {
            case .PrivacyRestricted:
                return "[EventKit] Error getting all calendars: Error Domain=EKCADErrorDomain Code=1019"
            }
        }
    }
    
    /**
     - precondition: Be sure to check if the user has granted access to the calendar.
     Thus, initalizing this struct is best in a lazy var and only needed AFTER
     access has been checked with PrivacyService.Calendar.authorize(..)
     
     - postcondition: Use any of this struct's methods in insurance that privacy
     will not be restricted after this initalizer
     
     - throws: due to user privacy
     */
    init(delegate: CalendarStackDelegate?) throws {
        let fetchedCalendars = eventStore.calendars(for: EKEntityType.event)
        
        // Since the stock calendar app does not allow you to delete all calendars
        //stored locally, this is how we'll know if fetching for calendars was limited due to privacy
        guard fetchedCalendars.count != 0 else {
                throw CalendarStackErrors.PrivacyRestricted
        }
        
        self.calendars = fetchedCalendars
        self.delegate = delegate
        
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CalendarStack.eventStoreDidChange(_:)),
            name: NSNotification.Name.EKEventStoreChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CalendarStack.calendarServiceDidUpdateStaleSessions(_:)),
            name: NSNotification.Name.CalendarServiceDidUpdateStaleSessions,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - RETURN VALUES
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - postcondition: events are saved
     
     - returns: the newly created event
     */
    @discardableResult
    func createEvent(with title: String, startDate: Date, endDate: Date) -> EKEvent {
        //TODO: http://irekasoft.com/blog/ios-user-data-calendar
        
        let newEvent = EKEvent(eventStore: self.eventStore)
        newEvent.title = title
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.calendar = self.eventStore.defaultCalendarForNewEvents
        
        self.save(event: newEvent)
        
        return newEvent
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    func events(for date: Date) -> [EKEvent] {
        let startDate = date.midnight
        let endDate = date.endOfDay
        
        // Use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        // Use the configured NSPredicate to find and return events in the store that match
        return eventStore.events(matching: eventsPredicate).sorted() {
            (e1: EKEvent, e2: EKEvent) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        }
    }
    
    // MARK: - VOID METHODS
    
    @objc func eventStoreDidChange(_ notification: Notification) {
        self.delegate?.calendar?(stack: self, eventStoreDidChange: notification.object as! EKEventStore)
    }
    
    @objc func calendarServiceDidUpdateStaleSessions(_ notification: Notification) {
        self.delegate?.calendar?(stack: self, didUpdateStaleSessions: notification.object as! Set<Session>)
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    func save(event: EKEvent, for span: EKSpan = .thisEvent) {
        do {
            try self.eventStore.save(event, span: span)
        } catch let err {
            assertionFailure(err.localizedDescription)
        }
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    func delete(event: EKEvent, for span: EKSpan = .thisEvent) {
        do {
            try self.eventStore.remove(event, span: span)
        } catch let err {
            assertionFailure(err.localizedDescription)
        }
    }
    
    /**
     Present an editor view controller view w new event
     
     - warning: the new EKEvent is stored to this model's event store
     */
    func presentNewEvent(in viewController: UIViewController & EKEventEditViewDelegate) {
        let eventVC = EKEventEditViewController()
        eventVC.event = EKEvent(eventStore: self.eventStore)
        eventVC.editViewDelegate = viewController
        eventVC.eventStore = self.eventStore
        
        viewController.present(eventVC, animated: true)
    }
    
    /**
     Present a detailed view of the given event
     */
    func present(event: EKEvent?, in viewController: UIViewController & EKEventViewDelegate) {
        let eventVC = EKEventViewController()
        eventVC.event = event
        eventVC.delegate = viewController
        
        //FIXME: Double edit buttons
        eventVC.allowsEditing = true
        
        let navCon = UINavigationController(rootViewController: eventVC)
        navCon.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        
        viewController.present(navCon, animated: true)
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}
