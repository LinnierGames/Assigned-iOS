//
//  OrganizeRootTableViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/12/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CoreData

class OrganizeRootTableViewController: OrganizeTableViewController {
    
    private var viewModel = OrganizeViewModel()
    
    private var directoryManager = DirectoryManager()

    // MARK: - RETURN VALUES
    
    override func directoriesForSelectedIndexPaths() -> [Directory]? {
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return nil
        }
        
        let directories = selectedIndexPaths.map({ [unowned self] (indexPath) -> Directory in
            return self.fetchedResultsController.folder(at: IndexPath(row: indexPath.row, section: 0)).directory
        })
        
        return directories
    }
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3 // inbox, overdue, due soon
        } else {
            return super.tableView(tableView, numberOfRowsInSection: 0)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Folders"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            // smart cells
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UITitleIconTableViewCell.reusableIdentifier) as! UITitleIconTableViewCell? else {
                assertionFailure("custom cell did not load")
                
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            
            //TODO: make icons for smart cell
            if indexPath.row == 0 {
                cell.labelTitle.text = "Inbox"
            } else if indexPath.row == 1 {
                cell.labelTitle.text = "Overdue"
            } else {
                cell.labelTitle.text = "Due Soon"
            }
            
            return cell
        } else {
            
            // folder cells
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UITaskTableViewCell.Types.baseCell.cellIdentifier) as! UITaskTableViewCell?
                else {
                    assertionFailure("custom cell did not load")
                    
                    return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            
            let offsettedIndexPath = IndexPath(row: indexPath.row, section: 0)
            
            let folder = fetchedResultsController.folder(at: offsettedIndexPath)
            cell.configure(folder)
            
            return cell
        }
    }
    
    // MARK: - VOID METHODS
    
    override func updateFetch() {
        let fetch: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        //TODO: stringly typed
        fetch.sortDescriptors = [
            NSSortDescriptor(key: "title",
                             ascending: false,
                             selector: #selector(NSString.localizedStandardCompare(_:))
            )
        ]
        fetch.predicate = NSPredicate(format: "directory.parent == NULL")
        
        self.fetchedResultsController = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: fetch as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: viewModel.managedObjectContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        buttonAdd.isEnabled = editing.inverse
        if editing {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(OrganizeTableViewController.pressActionTools(_:)))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "item", style: .plain, target: self, action: #selector(OrganizeTableViewController.pressProfile(_:)))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                
            /** A folder */
            case UIStoryboardSegue.showChildDirectory:
                guard let vc = segue.destination as? OrganizeChildDirectoryTableViewController else {
                    fatalError("segue did not have a destination of OrganizeChildDirectoryTableViewController")
                }
                
                guard
                    let indexPath = sender as? IndexPath
                    else {
                        fatalError("\"show child directory\" was fired by something other than a table view cell did select")
                }
                let offsettedIndexPath = IndexPath(row: indexPath.row, section: 0)
                let selectedDirectory: Directory = self.fetchedResultsController.folder(at: offsettedIndexPath).directory
                
                vc.currentDirectory = selectedDirectory
            default:
                
                // move vc segue
                super.prepare(for: segue, sender: sender)
            }
        }
    }
    
    // MARK: Fetched Results Controller
    
    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let offsettedSectionIndex = 1
        
        super.controller(controller, didChange: sectionInfo, atSectionIndex: offsettedSectionIndex, for: type)
    }
    
    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let offsettedIndexPath: IndexPath? = {
            guard let indexPath = indexPath else {
                return nil
            }
            
            return IndexPath(row: indexPath.row, section: 1)
        }()
        let offsettedNewIndexPath: IndexPath? = {
            guard let newIndexPath = newIndexPath else {
                return nil
            }
            
            return IndexPath(row: newIndexPath.row, section: 1)
        }()
        
        super.controller(controller, didChange: anObject, at: offsettedIndexPath, for: type, newIndexPath: offsettedNewIndexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let offsettedIndexPath = IndexPath(row: indexPath.row, section: 0)
        
        super.tableView(tableView, commit: editingStyle, forRowAt: offsettedIndexPath)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            //TODO: segue to smart cells
        } else {
            let offsettedIndexPath = IndexPath(row: indexPath.row, section: 0)
            
            if tableView.isEditing == false {
                self.performSegue(withIdentifier: UIStoryboardSegue.showChildDirectory, sender: offsettedIndexPath)
            }
        }
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE

}

// MARK: - UIStoryboardSegue

fileprivate extension UIStoryboardSegue {
    static let showChildDirectory = "show child directory"
    static let showMove = "show move"
}
