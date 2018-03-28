//
//  AssignmentSessionViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/20/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CoreData

class AssignmentSessionViewController: UIViewController {
    
    private lazy var viewModel: SessionViewModel = {
        guard let model = self.parentNavigationViewController?.viewModel else {
            fatalError("parent navigation view controller was not set")
        }
        
        return SessionViewModel(with: model, delegate: self)
    }()
    
    private var dataModel: AssignmentNavigationViewModel {
        return viewModel.parentModel
    }
    
    weak var parentNavigationViewController: AssignmentNavigationViewController?
    
    var assignment: Assignment {
        set {
            dataModel.assignment = newValue
        }
        get {
            return dataModel.assignment
        }
    }

    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var tableSessions: UITableView!
    
    @IBAction func pressAddSession(_ sender: Any) {
        dataModel.addSession()
        dataModel.saveOnlyOnReading()
    }
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}

extension AssignmentSessionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //TODO: create sections for each day of the week
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedAssignmentSessions.sections?[section].objects?.count ?? 0
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if let fetchedSections = self.fetchedResultsController.sections {
//            guard
//                let fetchedSessions = fetchedSections[section].objects as? [Session]?,
//                let sessions = fetchedSessions,
//                let aSession = sessions.first else {
//                fatalError("fetched results controller did not fetch Sessions")
//            }
//
//            let formattedDate = String(date: aSession.date!, dateStyle: .short)
//
//            return formattedDate
//        } else {
//            return nil
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let session = viewModel.fetchedAssignmentSessions.session(at: indexPath)
        cell.textLabel!.text = session.name
        cell.detailTextLabel!.text = String(date: session.date!, dateStyle: .none, timeStyle: .short)
        
        //TODO: session location from the calendar event
//        cell.detailTextLabel!.text = session.lcoation
        
        return cell
    }
}

extension AssignmentSessionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableSessions.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableSessions.insertSections([sectionIndex], with: .fade)
        case .delete: tableSessions.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableSessions.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableSessions.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableSessions.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableSessions.deleteRows(at: [indexPath!], with: .fade)
            tableSessions.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableSessions.endUpdates()
    }
}
