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

    weak var delegate: AssignedViewModelDelegate?

    unowned var parentModel: AssignmentNavigationViewModel

    init(with parentModel: AssignmentNavigationViewModel, delegate: AssignedViewModelDelegate) {
        self.delegate = delegate
        self.parentModel = parentModel
    }

    //TODO: bridge
    var editingMode: CRUD {
        set {
            self.parentModel.editingMode = newValue
        }
        get {
            return self.parentModel.editingMode
        }
    }

    var context: NSManagedObjectContext {
        return self.parentModel.context
    }

//    private var persistance = PersistenceStack.shared

    lazy var fetchedAssignmentTasks: NSFetchedResultsController<Task> = {
        let fetch: NSFetchRequest<Task> = Task.fetchRequest()
        fetch.predicate = NSPredicate(format: "assignment == %@", assignment)
        fetch.sortDescriptors = [NSSortDescriptor.localizedStandardCompare(with: "title", ascending: true)]

        let fetchedRequestController = NSFetchedResultsController<Task>(
            fetchRequest: fetch,
            managedObjectContext: parentModel.context,
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

    // MARK: - RETURN VALUES

    // MARK: - VOID METHODS

    // MARK: - IBACTIONS

    // MARK: - LIFE CYCLE
}

extension AssignmentViewModel {

    /**
     - warning: read this value only after you've set the editingMode

     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     */
    var assignment: Assignment {
        return self.parentModel.assignment
    }

    var parentTitle: String? {
        if let parentDirectoryInfo = assignment.parentInfo {
            return parentDirectoryInfo.title
        } else {
            return "Braindump"
        }
    }

    func setPriority(to value: Assignment.Priorities) {
        assignment.priority = value
    }

    var deadlineSubtext: String? {
        if let deadline = assignment.deadline {
            let daysUntilDeadline = deadline.timeIntervalSinceNow

            //TODO: User Preferences
            //FIXME: use largest unit, weeks, days, hours, minutes, and grammar
            let text = String(timeInterval: daysUntilDeadline, options: .largestTwoUnits)

            // is the deadline overdue
            if daysUntilDeadline >= 0 {
                return "in \(text)"
            } else {
                return "overdue by \(text)"
            }
        } else {
            return nil
        }
    }

    var deadlineTitle: String? {
        if let deadline = assignment.deadline {
            return String(date: deadline, dateStyle: .medium, timeStyle: .short)
        } else {
            return nil
        }
    }

    func updateDeadline(to date: Date?) {
        self.assignment.deadline = date
    }

    //TODO: Add deadline presets
    func setDeadlineToToday() {
        assignment.deadline = Date()
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
}
