//
//  AssignmentNavigationViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/27/18.
//  Copyright © 2018 LinnierGames. All rights/Users/ericksanc/Developer/My Projects/Assigned/Universal iOS/Assigned/Assigned/AssignmentNavigationViewModel.swift reserved.
//

import Foundation
import CoreData

class AssignmentNavigationViewModel: NSObject {
    
    @objc dynamic var editingMode: CRUD = .Create {
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
    
    private lazy var calendar: CalendarStack = {
        do {
            return try CalendarStack(delegate: self)
        } catch let err {
            fatalError(err.localizedDescription)
        }
    }()
    
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
    func addSubtask(with title: String) -> Subtask {
        let newSubtask = Subtask(title: title, in: self.context)
        self.addSubtask(newSubtask)
        
        return newSubtask
    }
    
    func addSubtask(_ subtask: Subtask) {
        subtask.assignment = self.assignment
    }
    
    func delete(subtask: Subtask) {
        self.context.delete(subtask)
    }
    
    func save() {
        PersistenceStack.shared.saveContext(context: self.context)
    }
    
    // MARK: Sessions
    
    @discardableResult
    func addSession(with date: Date = Date()) -> Session {
        let newSession = Session(
            title: nil,
            startDate: date,
            assignment: self.assignment, in: self.context)
        addSession(session: newSession)
        
        return newSession
    }
    
    func addSession(session: Session) {
        session.assignment = self.assignment
        
        calendar.createEvent(for: session)
    }
    
    func delete(session: Session) {
        self.context.delete(session)
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}

// MARK: - CalendarStackDelegate

extension AssignmentNavigationViewModel: CalendarStackDelegate {
    func calendar(stack: CalendarStack, didUpdateStaleSessions updatedSessions: Set<Session>) {
        
        // Removes merge conflicts when saving after CalendarService has made its own changes from a stale Session update
        self.context.refreshAllObjects()
        
        //TODO: validate each mo in the given updatedSessions
    }
}

// MARK: - View Controller Get/Set

extension AssignmentNavigationViewModel {
    
    /**
     Creates a blank context with a new assigned MO
     */
    func createNewAssignment() {
        
        // set context to edits context
        self.updateContextToANewEditContext()
        
        //FIXME: get the parent directory
        let newAssignment = Assignment(
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
