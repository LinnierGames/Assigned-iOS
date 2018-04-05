//
//  CalendarTableViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/4/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import EventKit

class CalendarTableViewController: UITableViewController {
    
    let eventStore = EKEventStore()
    
    private var calendars: [EKCalendar]?
    
    // MARK: - RETURN VALUES
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let event = events![indexPath.row]
        cell.textLabel!.text = event.title
        
        let startTime = String(date: event.startDate, dateStyle: .none, timeStyle: .short)
        let endTime = String(date: event.endDate, dateStyle: .none, timeStyle: .short)
        cell.detailTextLabel!.text = "\(startTime) - \(endTime)"
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private
    func loadCalendars() {
        self.calendars = eventStore.calendars(for: EKEntityType.event)
    }
    
    var selectedCalendar: EKCalendar! // Passed in from previous view controller
    var events: [EKEvent]?
    
    func loadEvents() {
        
        // Create start and end date NSDate instances to build a predicate for which events to select
        let startDate = Date().midnight
        let endDate = Date().endOfDay
        
        if let calendars = self.calendars {
            let eventStore = EKEventStore()
            
            // Use an event store instance to create and properly configure an NSPredicate
            let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
            
            // Use the configured NSPredicate to find and return events in the store that match
            self.events = eventStore.events(matching: eventsPredicate).sorted() {
                (e1: EKEvent, e2: EKEvent) -> Bool in
                return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
            }
        }
    }
    
    private
    func refreshTableView() {
        self.tableView.reloadData()
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PrivacyService.Calendar.authorize(successfulHandler: {
            self.loadCalendars()
            self.loadEvents()
            self.refreshTableView()
        }) {
            UIAlertController(title: "Access to iCal", message: "Assigned needs to have access to your calendar. Please open the Settings app and enable Calendar", preferredStyle: .alert)
                .addConfirmationButton(title: "Open Settings", with: { (action) in
                    
                    // url to open settings
                    UIApplication.shared.openAppSettings()
                })
                .present(in: self)
        }
    }
}
