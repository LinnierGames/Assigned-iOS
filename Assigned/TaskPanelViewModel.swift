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
    
    var selectedDate: Date = Date()
    
    enum SearchFilter: Int {
        case SelectedDay = 0
        case Priority
        case AllTasks
        case None
    }
    
    var selectedFilter = SearchFilter.SelectedDay
    
    var fetchedTasks: NSFetchedResultsController<Assignment>?
    
    mutating func reloadTasks() {
        let fetch: NSFetchRequest<Assignment> = Assignment.fetchRequest()
        
        let sortDeadline = NSSortDescriptor(key: Assignment.StringKeys.deadline, ascending: false)
        let sortPriority = NSSortDescriptor(key: Assignment.StringKeys.priorityValue, ascending: false)
        let sortTitle = NSSortDescriptor.localizedStandardCompare(with: Assignment.StringKeys.title, ascending: false)
        switch selectedFilter {
        case .SelectedDay:
            fetch.predicate = NSPredicate(date: self.selectedDate, for: "deadline")
            fetch.sortDescriptors = [
                sortDeadline,
                sortPriority,
                sortTitle
            ]
        case .Priority:
            fetch.predicate = nil
            fetch.sortDescriptors = [
                sortPriority,
                sortDeadline,
                sortTitle
            ]
        case .AllTasks:
            fetch.predicate = nil
            fetch.sortDescriptors = [
                sortDeadline,
                sortPriority,
                sortTitle
            ]
        case .None:
            fetch.sortDescriptors = [
                sortDeadline
            ]
        }
        
        self.fetchedTasks = NSFetchedResultsController<Assignment>(
            fetchRequest: fetch,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
        do {
            try fetchedTasks!.performFetch()
            fetchedTasks!.delegate = self.delegate
        } catch let error {
            assertionFailure(String(describing: error))
        }
    }
}
