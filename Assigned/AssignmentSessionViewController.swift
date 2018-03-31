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
    
    private func presentSessionDetail(for session: Session) {
        self.performSegue(withIdentifier: "show session details", sender: session)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show session details":
                guard let vc = segue.destination as? SessionDetailedController else {
                    fatalError("destination is not set up as a SessionDetailedController")
                }
                
                guard let session = sender as? Session else {
                    fatalError("a session was not sent as the sender")
                }
                
                vc.session = session
                vc.delegate = self
            default: break
            }
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var tableSessions: UITableView!
    
    @IBAction func pressAddSession(_ sender: Any) {
        let newSession = dataModel.addSession()
        dataModel.saveOnlyOnReading()
        self.presentSessionDetail(for: newSession)
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
        return viewModel.fetchedAssignmentSessions.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedAssignmentSessions.sections?[section].objects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let fetchedSections = self.viewModel.fetchedAssignmentSessions.sections {
            guard
                let fetchedSessions = fetchedSections[section].objects as? [Session]?,
                let sessions = fetchedSessions,
                let aSession = sessions.first else {
                fatalError("fetched results controller did not fetch Sessions")
            }

            let formattedDate = String(date: aSession.dayOfStartDate, dateStyle: .long)

            return formattedDate
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let session = viewModel.fetchedAssignmentSessions.session(at: indexPath)
        
        //TODO: udpate if the assignment title gets updated
        cell.textLabel!.text = session.title
        
        let startingDate = String(date: session.startDate, dateStyle: .short, timeStyle: .short)
        let endingDate = String(date: session.startDate.addingTimeInterval(session.durationValue), dateStyle: .none, timeStyle: .short)
        cell.detailTextLabel!.text = "\(startingDate) till \(endingDate)"
        
        //TODO: session location from the calendar event
//        cell.detailTextLabel!.text = session.lcoation
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let session = self.viewModel.fetchedAssignmentSessions.session(at: indexPath)
        self.presentSessionDetail(for: session)
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

extension AssignmentSessionViewController: SessionDetailedControllerDelegate {
    func session(controller: SessionDetailedController, didFinishEditing session: Session) {
        dataModel.saveOnlyOnReading()
    }
    
    func session(controller: SessionDetailedController, didDelete session: Session) {
        dataModel.delete(session: session)
        dataModel.saveOnlyOnReading()
    }
}
