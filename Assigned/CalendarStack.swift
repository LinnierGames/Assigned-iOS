//
//  CalendarStack.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import EventKitUI

struct CalendarStack {
    
    //TODO: listen for changes made in the calendar and notify anyone listening
    
    private(set) var eventStore = EKEventStore()
    
    var calendars: [EKCalendar]
    
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
     - throws: due to user privacy
     */
    init() throws {
        let fetchedCalendars = eventStore.calendars(for: EKEntityType.event)
        
        // Since the stock calendar app does not allow you to delete all calendars
        //stored locally, this is how we'll know if fetching for calendars was limited due to privacy
        guard fetchedCalendars.count != 0 else {
                throw CalendarStackErrors.PrivacyRestricted
        }
        
        self.calendars = fetchedCalendars
    }
    
    // MARK: - RETURN VALUES
    
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
    
    /**
     Present an editor view controller view w new event
     
     - warning: the new EKEvent is stored to this model's event store
     */
    func presentNewEvent(for viewController: UIViewController & EKEventEditViewDelegate) {
        
        let eventVC = EKEventEditViewController()
        eventVC.event = EKEvent(eventStore: self.eventStore)
        eventVC.editViewDelegate = viewController
        eventVC.eventStore = self.eventStore
        
        viewController.present(eventVC, animated: true)
        
    }
    
    /**
     Present a detailed view of the given event
     */
    func present(event: EKEvent?, for viewController: UIViewController & EKEventViewDelegate) {
        
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
