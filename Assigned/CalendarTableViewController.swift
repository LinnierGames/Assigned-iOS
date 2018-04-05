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
    
    lazy var calendar = {
        return try! CalendarStack()
    }()
    
    var events: [EKEvent]?
    
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
    func refreshTableView() {
        self.events = calendar.events(for: Date())
        self.tableView.reloadData()
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PrivacyService.Calendar.authorize(successfulHandler: {
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
