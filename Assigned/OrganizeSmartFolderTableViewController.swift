//
//  OrganizeSmartFolderTableViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/12/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CoreData

class OrganizeSmartFolderTableViewController: OrganizeTableViewController {
    
    private var viewModel = OrganizeViewModel()
    
    private var directoryManager = DirectoryManager()
    
    enum SmartFolder {
        case Inbox
        case Overdue
        case DueSoon
    }
    
    var smartFolderType: SmartFolder!

    // MARK: - RETURN VALUES
    
    override func directoriesForSelectedIndexPaths() -> [Directory]? {
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return nil
        }
        
        let directories = selectedIndexPaths.map({ [unowned self] (indexPath) -> Directory in
            
            switch self.smartFolderType {
            case .Inbox:
                return self.fetchedResultsController.directory(at: indexPath)
            case .Overdue:
                return self.fetchedResultsController.task(at: indexPath).directory
            case .DueSoon:
                fatalError("not implemented")
            default:
                fatalError("should not be nil")
            }
        })
        
        return directories
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITaskTableViewCell.Types.baseCell.cellIdentifier) as! UITaskTableViewCell?
            else {
                assertionFailure("custom cell did not load")
                
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        switch self.smartFolderType {
        case .Inbox:
            let directory = fetchedResultsController.directory(at: indexPath)
            //TODO: DRY by using an interface
            switch directory.info {
            case is Folder:
                let folder = directory.folder
                cell.configure(folder)
            case is Task:
                let task = directory.task
                cell.configure(task)
            default:
                break
            }
        case .Overdue:
            let task = fetchedResultsController.task(at: indexPath)
            cell.configure(task)
        case .DueSoon:
            break
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    override func updateFetch() {
        
        switch self.smartFolderType {
        case .Inbox:
            //TODO: fetch all but folders
            let fetch: NSFetchRequest<Directory> = Directory.fetchRequest()
            fetch.sortDescriptors = [
                NSSortDescriptor(key: "\(Directory.StringKeys.info).\(DirectoryInfo.StringKeys.title)",
                    ascending: false,
                    selector: #selector(NSString.localizedStandardCompare(_:))
                )
            ]
            
            fetch.predicate = NSPredicate(format: "\(Directory.StringKeys.parent) == NULL")
            
            self.fetchedResultsController = NSFetchedResultsController<NSManagedObject>(
                fetchRequest: fetch as! NSFetchRequest<NSManagedObject>,
                managedObjectContext: viewModel.managedObjectContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
        case .Overdue:
            let fetch: NSFetchRequest<Task> = Task.fetchRequest()
            fetch.sortDescriptors = [
                NSSortDescriptor(key: "\(Task.StringKeys.deadline)",
                    ascending: false
                )
            ]
            
            fetch.predicate = NSPredicate(format: "\(Task.StringKeys.deadline) <= %@", NSDate())
            
            self.fetchedResultsController = NSFetchedResultsController<NSManagedObject>(
                fetchRequest: fetch as! NSFetchRequest<NSManagedObject>,
                managedObjectContext: viewModel.managedObjectContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
        case .DueSoon:
            break
        default: // optional
            fatalError("should not be nil")
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        //        buttonAdd.isEnabled = editing.inverse
        if editing {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(pressActionTools(_:)))
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                /** an task Vc */
            case UIStoryboardSegue.showDetailedTask:
                guard let navVc = segue.destination as? TaskNavigationViewController else {
                    fatalError("segue did not have a destination of TaskNavigationViewController")
                }
                
                // modifying an exsiting task or adding a new one?
                if let indexPath = sender as? IndexPath {
                    
                    let selectedTask: Task
                    
                    switch self.smartFolderType {
                    case .Inbox:
                        let selectedDirectory = self.fetchedResultsController.directory(at: indexPath)
                        selectedTask = selectedDirectory.task
                    case .Overdue:
                        selectedTask = self.fetchedResultsController.task(at: indexPath)
                    case .DueSoon:
                        fatalError("not implemented")
                    default:
                        fatalError("should not be nil")
                    }
                    
                    
                    navVc.task = selectedTask
                    navVc.editingMode = .Read
                    
                    // adding a new task
                } else {
                    navVc.editingMode = .Create
                    navVc.taskParentDirectory = self.currentDirectory
                }
            default:
                super.prepare(for: segue, sender: sender)
            }
        }
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == false {
            let directory: Directory
            
            switch self.smartFolderType {
            case .Inbox:
                directory = fetchedResultsController.directory(at: indexPath)
            case .Overdue:
                directory = fetchedResultsController.task(at: indexPath).directory
            case .DueSoon:
                fatalError("not implemented")
            default:
                fatalError("should not be nil")
            }
            
            if directory.isFolder {
                self.performSegue(withIdentifier: UIStoryboardSegue.showChildDirectory, sender: indexPath)
            } else if directory.isTask {
                self.performSegue(withIdentifier: UIStoryboardSegue.showDetailedTask, sender: indexPath)
            }
        }
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch self.smartFolderType {
        case .Inbox:
            self.title = "Inbox"
        case .Overdue:
            self.title = "Overdue"
            //TODO: remove add button
        case .DueSoon:
            self.title = "Due Soon"
        default:
            fatalError("should not be nil")
        }
    }

}

// MARK: - UIStoryboardSegue

fileprivate extension UIStoryboardSegue {
    static let showChildDirectory = "show child directory"
    static let showDetailedTask = "show detailed task"
    static let showMove = "show move"
}
