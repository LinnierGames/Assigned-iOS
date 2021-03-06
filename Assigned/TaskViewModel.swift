//
//  TaskViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/10/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import CoreData

class TaskViewModel {

    typealias AssignedViewModelDelegate = NSFetchedResultsControllerDelegate

    weak var delegate: AssignedViewModelDelegate?

    unowned var parentModel: TaskNavigationViewModel

    init(with parentModel: TaskNavigationViewModel, delegate: AssignedViewModelDelegate) {
        self.delegate = delegate
        self.parentModel = parentModel
    }

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

    lazy var fetchedSubtasks: NSFetchedResultsController<Subtask> = {
        let fetch: NSFetchRequest<Subtask> = Subtask.fetchRequest()
        fetch.predicate = NSPredicate(format: "\(Subtask.StringKeys.task) == %@", task)
        fetch.sortDescriptors = [NSSortDescriptor.localizedStandardCompare(with: Subtask.StringKeys.title, ascending: true)]

        let fetchedRequestController = NSFetchedResultsController<Subtask>(
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

extension TaskViewModel {

    /**
     - warning: read this value only after you've set the editingMode

     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     */
    var task: Task {
        return self.parentModel.task
    }

    var parentTitle: String? {
        if let parentDirectoryInfo = task.parentInfo {
            return parentDirectoryInfo.title
        } else {
            return "Braindump"
        }
    }

    func setPriority(to value: Task.Priorities) {
        task.priority = value
    }

    var deadlineSubtext: String? {
        if let deadline = task.deadline {
            let daysUntilDeadline = deadline.timeIntervalSinceNow

            //A/B: User Preferences
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
        if let deadline = task.deadline {
            return String(date: deadline, dateStyle: .medium, timeStyle: .short)
        } else {
            return nil
        }
    }

    func updateDeadline(to date: Date?) {
        self.task.deadline = date
    }

    //TODO: Add deadline presets
    func setDeadlineToToday() {
        task.deadline = Date()
    }

    var effortTitle: String {
        if task.durationValue == 0 {
            return "no effort"
        } else {
            let nHours = TimeInterval(task.durationValue)

            return String(timeInterval: nHours, units: .day, .hour, .minute)
        }
    }

    // MARK: - RETURN VALUES

    // MARK: - VOID METHODS
}
