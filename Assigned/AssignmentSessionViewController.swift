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
        PrivacyService.Calendar.authorize(
            
            successfulHandler: { [weak self] in
                guard let unwrappedSelf = self else { return }
                
                let newSession = unwrappedSelf.dataModel.addSession()
                unwrappedSelf.dataModel.saveOnlyOnReading()
                unwrappedSelf.presentSessionDetail(for: newSession)
                
        }, failureHandler: {
            PrivacyService.Calendar.promptAlert(in: self, with: .alert)
        })
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

// MARK: - UITableViewDataSource, UITableViewDelegate

extension AssignmentSessionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let fetchedResults = viewModel.fetchedAssignmentSessions {
            
            //TODO: create sections for each day of the week
            return fetchedResults.sections?.count ?? 0
            
            // privacy message cell
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchedResults = viewModel.fetchedAssignmentSessions {
            return fetchedResults.sections?[section].objects?.count ?? 0
            
        // privacy message cell
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let fetchedResults = viewModel.fetchedAssignmentSessions {
            if let fetchedSections = fetchedResults.sections {
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
            
        // privacy message cell
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let fetchedResults = viewModel.fetchedAssignmentSessions {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            let session = fetchedResults.session(at: indexPath)
            
            //TODO: udpate if the assignment title gets updated
            cell.textLabel!.text = session.title
            
            let startingDate = String(date: session.startDate, dateStyle: .short, timeStyle: .short)
            let endingDate = String(date: session.startDate.addingTimeInterval(session.durationValue), dateStyle: .none, timeStyle: .short)
            cell.detailTextLabel!.text = "\(startingDate) till \(endingDate)"
            
            //TODO: session location from the calendar event
            //        cell.detailTextLabel!.text = session.lcoation
            
            return cell
            
            // privacy message cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell message")
            
            cell.textLabel!.text = "Needs access to Calendar"
            cell.detailTextLabel!.text = "Assigned needs access to the Calendar to add sessions"
            cell.detailTextLabel!.numberOfLines = 2
            cell.isUserInteractionEnabled = false //don't allow the cell to be selected and invoke the tableView(tableView:, didSelectRowAt:)

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fetchedAssignments = self.viewModel.fetchedAssignmentSessions else {
            return assertionFailure("table view was populated with some rows but the fetched results controller became nil when selceting a row")
        }
        
        let session = fetchedAssignments.session(at: indexPath)
        self.presentSessionDetail(for: session)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

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

// MARK: - SessionDetailedControllerDelegate

extension AssignmentSessionViewController: SessionDetailedControllerDelegate {
    func session(controller: SessionDetailedController, didFinishEditing session: Session) {
        dataModel.saveOnlyOnReading()
    }
    
    func session(controller: SessionDetailedController, didDelete session: Session) {
        dataModel.delete(session: session)
        dataModel.saveOnlyOnReading()
    }
}
