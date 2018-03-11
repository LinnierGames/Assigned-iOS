//
//  AssignmentViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/10/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import CoreData

class AssignmentViewModel {
    
    typealias AssignedViewModelDelegate = NSFetchedResultsControllerDelegate
    
    var delegate: AssignedViewModelDelegate?
    
    private var persistance = PersistenceStack.shared
    
    private var assignmentValue: Assignment!
    
    init(with delegate: AssignedViewModelDelegate) {
        self.delegate = delegate
    }
    
    var managedObjectContext: NSManagedObjectContext {
        return persistance.viewContext
    }
    
    var assignment: Assignment! {
        set {
            self.assignmentValue = newValue
        }
        get {
            if self.assignmentValue == nil {
                let newAssignment = Assignment(title: "Untitled", effort: 0, in: managedObjectContext)
                //FIXME: get the parent directory
                _ = Directory.createDirectory(for: newAssignment, parent: nil, in: managedObjectContext)
                self.assignmentValue = newAssignment
            }
            
            return self.assignmentValue
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func addTask(with title: String) {
        let newTask = Task(title: title, in: self.managedObjectContext)
        self.addTask(newTask)
    }
    
    func addTask(_ task: Task) {
        task.assignment = assignment
        self.save()
    }
    
    func save() {
        persistance.saveContext()
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    lazy var assignmentTasks: NSFetchedResultsController<Task>? = {
        let fetch: NSFetchRequest<Task> = Task.fetchRequest()
        fetch.predicate = NSPredicate(format: "assignment == %@", assignment)
        fetch.sortDescriptors = [NSSortDescriptor.localizedStandardCompare(with: "title")]
        
        let fetchedRequestController = NSFetchedResultsController<Task>(
            fetchRequest: fetch,
            managedObjectContext: self.managedObjectContext,
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
