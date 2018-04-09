//
//  SessionViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/27/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import CoreData

class SessionViewModel {
    
    typealias SessionViewModelDelegate = NSFetchedResultsControllerDelegate
    
    weak var delegate: SessionViewModelDelegate?
        
    unowned var parentModel: TaskNavigationViewModel
    
    private(set) var isShowingPastSessions = false
    
    var fetchedSessions: NSFetchedResultsController<Session>?
    
    init(with parentModel: TaskNavigationViewModel, delegate: SessionViewModelDelegate) {
        self.parentModel = parentModel
        self.delegate = delegate
        
        self.reloadFetch()
    }
    
    // MARK: - RETURN VALUES
    
    var context: NSManagedObjectContext {
        return self.parentModel.context
    }
    
    var task: Task {
        return self.parentModel.task
    }
    
    func reloadFetch() {
        
        // Privacy Restriction
        guard PrivacyService.Calendar.isAuthorized else {
            
            // Calendar was not granted access
            self.fetchedSessions = nil
            
            return
        }
        
        let fetch: NSFetchRequest<Session> = Session.fetchRequest()
        
        //A/B: past sessions means after the today's time or after today's date
        if self.isShowingPastSessions {
            fetch.sortDescriptors = [NSSortDescriptor(key: Session.StringKeys.startDate, ascending: false)]
            fetch.predicate = NSPredicate(format: "\(Session.StringKeys.task) == %@ AND \(Session.StringKeys.startDate) < %@", self.task, Date().midnight as NSDate)
        } else {
            fetch.sortDescriptors = [NSSortDescriptor(key: Session.StringKeys.startDate, ascending: true)]
            fetch.predicate = NSPredicate(format: "\(Session.StringKeys.task) == %@ AND \(Session.StringKeys.startDate) >= %@", self.task, Date().midnight as NSDate)
        }
        
        let fetchedRequestController = NSFetchedResultsController<Session>(
            fetchRequest: fetch,
            managedObjectContext: self.context,
            sectionNameKeyPath: Session.StringKeys.dayOfStartDate, cacheName: nil
        )
        
        do {
            try fetchedRequestController.performFetch()
            fetchedRequestController.delegate = self.delegate
        } catch let error {
            assertionFailure(String(describing: error))
        }
        
        self.fetchedSessions = fetchedRequestController
    }
    
    // MARK: - VOID METHODS
    
    func toggleShowPastSessions() {
        self.isShowingPastSessions.invert()
        reloadFetch()
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
}

extension SessionViewModel {
    
    var isAuthorizedForCalendarEvents: Bool {
        return PrivacyService.Calendar.isAuthorized
    }
}
