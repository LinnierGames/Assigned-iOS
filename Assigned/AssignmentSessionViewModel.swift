//
//  AssignmentSessionViewModel.swift
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
        
    unowned var parentModel: AssignmentNavigationViewModel
    
    lazy var fetchedAssignmentSessions: NSFetchedResultsController<Session>? = {
        
        // Privacy Restriction
        guard PrivacyService.Calendar.isAuthorized else {
            
            // Calendar was not granted access
            return nil
        }
        
        let fetch: NSFetchRequest<Session> = Session.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        fetch.predicate = NSPredicate(format: "assignment == %@", self.assignment)
        
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
        
        return fetchedRequestController
    }()
    
    init(with parentModel: AssignmentNavigationViewModel, delegate: SessionViewModelDelegate) {
        self.parentModel = parentModel
        self.delegate = delegate
    }
    
    // MARK: - RETURN VALUES
    
    var context: NSManagedObjectContext {
        return self.parentModel.context
    }
    
    var assignment: Assignment {
        return self.parentModel.assignment
    }
    
    var isAuthorizedForCalendarEvents: Bool {
        return PrivacyService.Calendar.isAuthorized
    }
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
}

extension SessionViewModel {
}
