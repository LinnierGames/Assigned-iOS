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
    
    var editingMode: CRUD = .Create {
        didSet {
            switch editingMode {
            case .Create:
                self.createNewAssignment()
            case .Read:
                break
            case .Update:
                break
            case .Delete:
                break
            }
        }
    }
    
    init(with delegate: AssignedViewModelDelegate) {
        self.delegate = delegate
    }
    
    private var persistance = PersistenceStack.shared
    
    lazy var context: NSManagedObjectContext = {
        return persistance.viewContext
    }()
    
    private var assignmentValue: Assignment!
    
    private var readingAssignmentValue: Assignment?
    
    // MARK: - RETURN VALUES
    
    /**
     creates and new context as a child of the viewContext
     
     - warning: the child context is a mainQueueConcurrencyType
     */
    private func newEditsContext() -> NSManagedObjectContext {
        return persistance.viewContext.newChildContext()
    }
    
    private func mainContext() -> NSManagedObjectContext {
        return persistance.viewContext
    }
    
    // MARK: - VOID METHODS
    
    func addTask(with title: String) {
        let newTask = Task(title: title, in: self.context)
        self.addTask(newTask)
    }
    
    func addTask(_ task: Task) {
        task.assignment = assignment
    }
    
    func deleteTask(at indexPath: IndexPath) {
        let task = fetchedAssignmentTasks.task(at: indexPath)
        self.context.delete(task)
    }
    
    func save() {
        self.persistance.saveContext()
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    lazy var fetchedAssignmentTasks: NSFetchedResultsController<Task> = {
        let fetch: NSFetchRequest<Task> = Task.fetchRequest()
        fetch.predicate = NSPredicate(format: "assignment == %@", assignment)
        fetch.sortDescriptors = [NSSortDescriptor.localizedStandardCompare(with: "title")]
        
        let fetchedRequestController = NSFetchedResultsController<Task>(
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

extension AssignmentViewModel {
    private func updateContextToANewEditContext() {
        let editContext = self.newEditsContext()
        self.context = editContext
    }
    
    private func updateContextToMainContext() {
        guard let readingAssignment = readingAssignmentValue else {
            fatalError("discard changes was called without an orignal returning point")
        }
        
        // switch back to the main context
        self.context = self.mainContext()
        
        // revert the assignment back to the readingAssignment, which was set before editing started
        assignment = readingAssignment
    }
    
    private func pushChangesToParentAndSave() {
        
        // push changes to parent
        self.persistance.saveContext(context: self.context)
        
        // save parent changes
        self.persistance.saveContext()
    }
}

extension AssignmentViewModel {
    
    var assignment: Assignment {
        set {
            self.assignmentValue = newValue
        }
        get {
            return self.assignmentValue
        }
    }
    
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
    
    func setPriority(to value: Assignment.Priorities) {
        assignment.priority = value
    }
    
    var deadlineSubtext: String? {
        if let deadline = assignmentValue.deadline {
            let daysUntilDeadline = deadline.timeIntervalSinceNow
            
            //TODO: User Preferences
            //FIXME: use largest unit, weeks, days, hours, minutes, and grammar
            let nDays = String(timeInterval: daysUntilDeadline, units: .day)
            
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
    
    var effortTitle: String {
        if assignment.effortValue == 0 {
            return "no effort"
        } else {
            let nHours = TimeInterval(assignment.effortValue)
            
            return String(timeInterval: nHours, units: .day, .hour, .minute)
        }
    }

    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    /**
     Creates a blank context with a new assigned MO
     */
    func createNewAssignment() {
        
        // set context to edits context
        self.updateContextToANewEditContext()
        
        //FIXME: get the parent directory
        let newAssignment = Assignment.createAssignment(
            title: "Untitled Assignment",
            effort: 0,
            parent: nil,
            in: self.context
        )
        
        self.assignment = newAssignment
    }
    
    /**
     pushes changes from the editing context to its parent, the main context,
     and saves the parent context.
     */
    func saveNewAssignment() {
        self.pushChangesToParentAndSave()
    }
    
    /**
     creates an editing context with a fetched copy of the assigned MO from the
     main context
     
     - precondition: assignmentValue must already be set
     */
    func beginEdits() {
        
        // create edit context
        self.updateContextToANewEditContext()
        
        // fetch a copy of assignment, from view context, to new edit context
        readingAssignmentValue = assignment
        assignment = self.context.object(with: assignment.objectID) as! Assignment
    }
    
    /**
     the trash button was pressed
     */
    func deleteAssignment() {
        
        // discard any changes
        self.context.delete(assignment)
        
        // push changes to parent and save the parent
        self.pushChangesToParentAndSave()
    }
    
    /**
     the discard button was pressed
     */
    func discardChanges() {
        self.updateContextToMainContext()
    }
    
    /**
     pushes changes from the editing context to its parent, just like saveNewAssignment(),
     but also switches back from the edit context to the main context.
     
     - warning: the edit context is deleted after pushing changes up to its parent
     */
    func saveEdits() {
        self.pushChangesToParentAndSave()
        self.updateContextToMainContext()
    }
    
    /**
     Only call this method if the view controller is not in any other mode other
     than isReading
     */
    func saveOnlyOnReading() {
        self.save()
    }

}

