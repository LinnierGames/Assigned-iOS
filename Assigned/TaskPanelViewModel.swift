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
//        case Urgency = 0
        case AllTasks = 0
        case SelectedDay
//        case Priority
    }
    
    var selectedFilter = SearchFilter.AllTasks
    
    var isShowingCompletedTasks: Bool = false
    
    var fetchedTasks: NSFetchedResultsController<Task>?
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    mutating func reloadTasks() {
        let fetch: NSFetchRequest<Task> = Task.fetchRequest()

        // unsupported sort
//        let sortDeadline = NSSortDescriptor(key: Task.StringKeys.deadline, ascending: true) { (a, b) -> ComparisonResult in
//            let a = a as! Task
//            let aD = a.deadline
//
//            let b = b as! Task
//            let bD = b.deadline
//
//            if aD == nil {
//                if bD == nil {
//                    return ComparisonResult.orderedSame
//                } else {
//                    return ComparisonResult.orderedAscending
//                }
//            } else {
//                if bD == nil {
//                    return ComparisonResult.orderedDescending
//                } else {
//                    return aD!.compare(bD!)
//                }
//            }
//        }
//        let sortCompleted = NSSortDescriptor(key: Task.StringKeys.isCompleted, ascending: true)
        
        let sortDeadline = NSSortDescriptor(key: Task.StringKeys.deadline, ascending: true)
//        let sortPriority = NSSortDescriptor(key: Task.StringKeys.priorityValue, ascending: false)
        let sortTitle = NSSortDescriptor.localizedStandardCompare(with: Task.StringKeys.title, ascending: false)
        switch selectedFilter {
//        case .Urgency:
//            //TODO: sort by urgency
//            fetch.predicate =
//                NSPredicate(date: self.selectedDate, forKey: Task.StringKeys.deadline)
//                    .appending(predicate: NSPredicate(format: "\(Task.StringKeys.isCompleted) == %@", NSNumber(value: isShowingCompletedTasks)))
//            fetch.sortDescriptors = [
//                sortDeadline,
//                sortTitle
//            ]
        case .AllTasks:
            fetch.predicate = NSPredicate(format: "\(Task.StringKeys.isCompleted) == %@", NSNumber(value: isShowingCompletedTasks))
            fetch.sortDescriptors = [
                sortDeadline,
                sortTitle
            ]
        case .SelectedDay:
            fetch.predicate =
                NSPredicate(date: self.selectedDate, forKey: Task.StringKeys.deadline)
                    .appending(predicate: NSPredicate(format: "\(Task.StringKeys.isCompleted) == %@", NSNumber(value: isShowingCompletedTasks)))
            fetch.sortDescriptors = [
                sortDeadline,
                sortTitle
            ]
//        case .Priority:
//            fetch.predicate = nil
//            fetch.sortDescriptors = [
//                sortPriority,
//                sortDeadline,
//                sortTitle
//            ]
        }
        
        self.fetchedTasks = NSFetchedResultsController<Task>(
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
    
    func deleteTask(at indexPath: IndexPath) {
        if let task = self.fetchedTasks?.task(at: indexPath) {
            self.context.delete(task)
        } else {
            assertionFailure("no task was found at the indexPath \(indexPath)")
        }
    }
    
    func save() {
        PersistenceStack.shared.saveContext(context: self.context)
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}

extension TaskPanelViewModel {
    
    var userHasCreatedFirstTask: Bool {
        
        //TODO: use user prefences to store the key-value of a bool instead of count
        let fetch: NSFetchRequest<Task> = Task.fetchRequest()
        guard let nTask = try? self.context.count(for: fetch) else {
            fatalError("fetch failed")
        }
        
        return nTask != 0
    }
    
    var fetchedNumberOfTasks: Int {
        if let nFetchedObjects = self.fetchedTasks?.fetchedObjects?.count {
            return nFetchedObjects
        } else {
            return 0
        }
    }
}
