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

extension AssignmentViewModel {
    
    var parentTitle: String? {
        guard let directory = assignment.directory else {
            fatalError("directory was not set")
        }
        
        if let parentDirectory = directory.parent {
            guard let parentInfo = parentDirectory.info else {
                fatalError("directory info was not set")
            }
            
            return parentInfo.title
        } else {
            return "Braindump"
        }
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
    
    func setPriority(to value: Assignment.Priorities) {
        assignment.priority = value
    }
    
    var deadlineSubtext: String? {
        if let deadline = assignmentValue.deadline {
            let daysUntilDeadline = deadline.timeIntervalSinceNow
            
            //TODO: User Preferences
            //FIXME: use largest unit, weeks, days, hours, minutes, and grammar
            let nDays = String(timeInterval: daysUntilDeadline, options: .day)
            
            return "in \(nDays)days"
        } else {
            return nil
        }
    }
    
    var deadlineTitle: String? {
        if let deadline = assignmentValue.deadline {
            return String(date: deadline, dateStyle: .medium, timeStyle: .short)
        } else {
            return nil
        }
    }
    
    func updateDeadline(to date: Date?) {
        self.assignmentValue.deadline = date
    }
    
    //TODO: Add deadline presets
    func setDeadlineToToday() {
        assignmentValue.deadline = Date()
    }
}

