//
//  TaskPanelViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/3/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import CoreData

struct TaskPanelViewModel {
    
    typealias TaskPanelViewModelDelegate = NSFetchedResultsControllerDelegate
    
    weak var delegate: TaskPanelViewModelDelegate?
    
    init(delegate: TaskPanelViewModelDelegate) {
        self.delegate = delegate
    }
    
    var context: NSManagedObjectContext = {
        return PersistenceStack.shared.viewContext
    }()
    
    lazy var fetchedTasks: NSFetchedResultsController<Assignment> = {
        let fetch: NSFetchRequest<Assignment> = Assignment.fetchRequest()
        
        let fetchedRequestController = NSFetchedResultsController<Assignment>(
            fetchRequest: fetch,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
        do {
            try fetchedRequestController.performFetch()
            fetchedRequestController.delegate = self.delegate
        } catch let error {
            assertionFailure(String(describing: error))
        }
        
        return fetchedRequestController
    }()
}
