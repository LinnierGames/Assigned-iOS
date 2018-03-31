//
//  AssignmentNavigationViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/27/18.
//  Copyright © 2018 LinnierGames. All rights/Users/ericksanc/Developer/My Projects/Assigned/Universal iOS/Assigned/Assigned/AssignmentNavigationViewModel.swift reserved.
//

import Foundation
import CoreData

class AssignmentNavigationViewModel {
    
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
    
    var assignment: Assignment!
    
    private var readingAssignmentValue: Assignment?
    
    // MARK: - RETURN VALUES
    
    /**
     creates and new context as a child of the viewContext
     
     - warning: the child context is a mainQueueConcurrencyType
     */
    private func newEditsContext() -> NSManagedObjectContext {
        return PersistenceStack.shared.viewContext.newChildContext()
    }
    
    private func mainContext() -> NSManagedObjectContext {
        return PersistenceStack.shared.viewContext
    }
    
    private(set) var context: NSManagedObjectContext = {
        return PersistenceStack.shared.viewContext
    }()
    
    // MARK: - VOID METHODS
    
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
        PersistenceStack.shared.saveContext(context: self.context)
        
        // save parent changes
        PersistenceStack.shared.saveContext()
    }
    
    // MARK: Subtasks
    
    @discardableResult
    func addTask(with title: String) -> Task {
        let newTask = Task(title: title, in: self.context)
        self.addTask(newTask)
        
        return newTask
    }
    
    func addTask(_ task: Task) {
        task.assignment = self.assignment
    }
    
    func delete(task: Task) {
        self.context.delete(task)
    }
    
    func save() {
        PersistenceStack.shared.saveContext()
    }
    
    // MARK: Sessions
    
    @discardableResult
    func addSession(with date: Date = Date()) -> Session {
        let newSession = Session(
            title: nil,
            startDate: date,
            assignment: self.assignment, in: self.context)
        
        return newSession
    }
    
    func addSession(session: Session) {
        session.assignment = self.assignment
    }
    
    func delete(session: Session) {
        self.context.delete(session)
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}

extension AssignmentNavigationViewModel {
    
    /**
     Creates a blank context with a new assigned MO
     */
    func createNewAssignment() {
        
        // set context to edits context
        self.updateContextToANewEditContext()
        
        //FIXME: get the parent directory
        let newAssignment = Assignment.createAssignment(
            title: "",
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
        if editingMode.isReading {
            self.save()
        }
    }
}
