//
//  OrganizeTableViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CoreData

class OrganizeTableViewController: FetchedResultsTableViewController {
    
    private var viewModel = OrganizeViewModel()
    
    private var directoryManager = DirectoryManager()
    
    var currentDirectory: Directory? {
        get {
            return self.viewModel.currentDirectory
        }
        set {
            self.viewModel.currentDirectory = newValue
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UIAssignmentTableViewCell.Types.baseCell.cellIdentifier) as! UIAssignmentTableViewCell?
            else {
                assertionFailure("custom cell did not load")
                
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        let directory = fetchedResultsController.directory(at: indexPath)
        //TODO: DRY by using an interface
        switch directory.info {
        case is Folder:
            let folder = directory.folder
            cell.configure(folder)
        case is Assignment:
            let assignment = directory.assignment
            cell.configure(assignment)
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        self.updateFetch()
    }
    
    private func updateFetch() {
        let fetch: NSFetchRequest<Directory> = Directory.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(key: "\(Directory.StringKeys.info).title",
                             ascending: false,
                             selector: #selector(NSString.localizedStandardCompare(_:))
            )
        ]
        
        if let parent = self.currentDirectory {
            fetch.predicate = NSPredicate(format: "parent == %@", parent)
        } else {
            fetch.predicate = NSPredicate(format: "parent == NULL")
        }
        
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
            case "show child directory":
                guard let vc = segue.destination as? OrganizeTableViewController else {
                    fatalError("segue did not have a destination of OrganizeTableViewController")
                }
                
                guard
                    let indexPath = sender as? IndexPath
                    else {
                        fatalError("\"show child directory\" was fired by something other than a table view cell did select")
                }
                
                let selectedDirectory = self.fetchedResultsController.directory(at: indexPath)
                vc.currentDirectory = selectedDirectory
                
            /** an assignment Vc */
            case "show detailed assignment":
                guard let navVc = segue.destination as? AssignmentNavigationViewController else {
                    fatalError("segue did not have a destination of AssignmentNavigationViewController")
                }
                
                // modifying an exsiting assignment or adding a new one?
                if let indexPath = sender as? IndexPath {
                    let selectedDirectory = self.fetchedResultsController.directory(at: indexPath)
                    navVc.assignment = selectedDirectory.assignment
                    navVc.editingMode = .Read
                    
                // adding a new assignment
                } else {
                    navVc.editingMode = .Create
                    navVc.assignmentParentDirectory = self.currentDirectory
                }
            default: break
            }
        }
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == false {
            let directory = fetchedResultsController.directory(at: indexPath)
            if directory.isFolder {
                self.performSegue(withIdentifier: UIStoryboardSegue.ShowChildDirectory, sender: indexPath)
            } else if directory.isAssignment {
                self.performSegue(withIdentifier: UIStoryboardSegue.ShowDetailedAssignment, sender: indexPath)
            }
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonProfile: UIBarButtonItem!
    @IBAction func pressProfile(_ sender: Any) {
        
    }
    
    @IBAction func pressActionTools(_ sender: Any) {
        UIAlertController(title: nil, message: "select an action", preferredStyle: .actionSheet)
            .addButton(title: "Duplicate") { [unowned self] (action) in
                guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
                    return //no rows selected TODO: disable the action tool button if none are selected
                }
                let directoriesToCopy = selectedIndexPaths.map({ [unowned self]  (indexPath) -> Directory in
                    return self.fetchedResultsController.directory(at: indexPath)
                })
                
                self.directoryManager.duplicate(directories: directoriesToCopy, to: self.currentDirectory)
//                self.viewModel.save()
            }
            .addButton(title: "Move to..") { (action) in
                
            }
            .addButton(title: "Delete..", style: .destructive) { (action) in
                
            }
            .addCancelButton()
            .present(in: self)
        
    }
    
    @IBOutlet weak var buttonEdit: UIBarButtonItem!
    
    @IBOutlet weak var buttonAdd: UIBarButtonItem!
    @IBAction func pressAdd(_ sender: Any) {
        /** <#Lorem ipsum dolor sit amet.#> */
        func add<T>(_ type: T.Type) where T: DirectoryInfo {
            let alertAddTitle = UIAlertController(
                title: type.description(),
                message: "enter a title",
                preferredStyle: .alert
            )
            
            alertAddTitle
                .addTextField()
                .addCancelButton()
                .addButton(title: "Add") { (action) in
                    if let newTitle = alertAddTitle.inputField.text {
                        switch type {
                        case is Assignment.Type:
                            self.viewModel.addAssignment(with: newTitle)
                        case is Folder.Type:
                            self.viewModel.addFolder(with: newTitle)
                        default: break
                        }
                    }
                }
                .present(in: self)

        }
        
        UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            .addButton(title: "Assignment", with: { [unowned self] (action) in
                self.performSegue(withIdentifier: "show detailed assignment", sender: nil)
            })
            .addButton(title: "Folder", with: { (action) in
                add(Folder.self)
            })
            .addCancelButton()
            .present(in: self)
        
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show the back button vs the profile button, and update title
        if currentDirectory != nil {
            navigationItem.leftBarButtonItem = nil
            self.title = currentDirectory!.info.title
        }
        
        let baseCell = UIAssignmentTableViewCell.Types.baseCell
        tableView.register(baseCell.nib, forCellReuseIdentifier: baseCell.cellIdentifier)
        
        //TODO: Dynamic Font, user preferences of which cell to display
        tableView.rowHeight = 44
        
        saveHandler = viewModel.save
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
    }

}

extension UIStoryboardSegue {
    static var ShowChildDirectory = "show child directory"
}
