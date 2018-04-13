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
    
    private func directoriesForSelectedIndexPaths() -> [Directory]? {
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return nil
        }
        
        let directories = selectedIndexPaths.map({ [unowned self] (indexPath) -> Directory in
            let offsettedIndexPath: IndexPath = { [unowned self] in
                if self.currentDirectory == nil {
                    return IndexPath(row: indexPath.row, section: 0)
                } else {
                    return indexPath
                }
            }()
            
            return self.fetchedResultsController.directory(at: offsettedIndexPath)
        })
        
        return directories
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.currentDirectory == nil {
            return 2
        } else {
            return super.numberOfSections(in: tableView)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentDirectory == nil {
            if section == 0 {
                return 3 // inbox, overdue, due soon
            } else {
                return super.tableView(tableView, numberOfRowsInSection: 0)
            }
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Folders"
        }
        
        return nil
    }
    
    private func taskFolderProjectCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITaskTableViewCell.Types.baseCell.cellIdentifier) as! UITaskTableViewCell?
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
        case is Task:
            let task = directory.task
            cell.configure(task)
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.currentDirectory == nil {
            if indexPath.section == 0 {
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
                let offsettedIndexPath: IndexPath = { [unowned self] in
                    if self.currentDirectory == nil {
                        return IndexPath(row: indexPath.row, section: 0)
                    } else {
                        return indexPath
                    }
                    }()
                
                return self.taskFolderProjectCell(tableView, cellForRowAt: offsettedIndexPath)
            }
        } else {
            return self.taskFolderProjectCell(tableView, cellForRowAt: indexPath)
        }
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
            fetch.predicate = NSPredicate(format: "\(Directory.StringKeys.parent) == %@", parent)
        } else {
            fetch.predicate = NSPredicate(format: "\(Directory.StringKeys.parent) == NULL")
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
            if currentDirectory == nil {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "item", style: .plain, target: self, action: #selector(OrganizeTableViewController.pressProfile(_:)))
            } else {
                self.navigationItem.leftBarButtonItem = nil
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                
            /** A folder */
            case UIStoryboardSegue.showChildDirectory:
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
                
            /** an task Vc */
            case UIStoryboardSegue.showDetailedTask:
                guard let navVc = segue.destination as? TaskNavigationViewController else {
                    fatalError("segue did not have a destination of TaskNavigationViewController")
                }
                
                // modifying an exsiting task or adding a new one?
                if let indexPath = sender as? IndexPath {
                    let selectedDirectory = self.fetchedResultsController.directory(at: indexPath)
                    navVc.task = selectedDirectory.task
                    navVc.editingMode = .Read
                    
                // adding a new task
                } else {
                    navVc.editingMode = .Create
                    navVc.taskParentDirectory = self.currentDirectory
                }
                
            /** move vc */
            case UIStoryboardSegue.showMove:
                guard
                    let navVc = segue.destination as? UINavigationController,
                    let moveVc = navVc.topViewController! as? MoveViewController,
                    let selectedDirectories = sender as? [Directory]
                    else {
                        fatalError("MoveTableViewController was not set in storyboard")
                }
                
                moveVc.items = selectedDirectories
                moveVc.delegate = self
            default: break
            }
        }
    }
    
    // MARK: Fetched Results Controller
    
    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let offsettedSectionIndex: Int = { [unowned self] in
            if self.currentDirectory == nil {
                return 1
            } else {
                return sectionIndex
            }
        }()
        
        super.controller(controller, didChange: sectionInfo, atSectionIndex: offsettedSectionIndex, for: type)
    }
    
    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let offsettedIndexPath: IndexPath? = { [unowned self] in
            guard let indexPath = indexPath else {
                return nil
            }
            
            if self.currentDirectory == nil {
                return IndexPath(row: indexPath.row, section: 1)
            } else {
                return indexPath
            }
        }()
        let offsettedNewIndexPath: IndexPath? = { [unowned self] in
            guard let newIndexPath = newIndexPath else {
                return nil
            }
            
            if self.currentDirectory == nil {
                return IndexPath(row: newIndexPath.row, section: 1)
            } else {
                return newIndexPath
            }
        }()
        
        super.controller(controller, didChange: anObject, at: offsettedIndexPath, for: type, newIndexPath: offsettedNewIndexPath)
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let offsettedIndexPath: IndexPath = { [unowned self] in
            if self.currentDirectory == nil {
                return IndexPath(row: indexPath.row, section: 0)
            } else {
                return indexPath
            }
        }()
        
        super.tableView(tableView, commit: editingStyle, forRowAt: offsettedIndexPath)
    }
    
    // MARK: Table View Delegate
    
    private func tableViewDidSelect(_ tableView: UITableView, indexPath: IndexPath) {
        if tableView.isEditing == false {
            let directory = fetchedResultsController.directory(at: indexPath)
            if directory.isFolder {
                self.performSegue(withIdentifier: UIStoryboardSegue.showChildDirectory, sender: indexPath)
            } else if directory.isTask {
                self.performSegue(withIdentifier: UIStoryboardSegue.showDetailedTask, sender: indexPath)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.currentDirectory == nil {
            if indexPath.section == 0 {
                //TODO: segue to smart cells
            } else {
                let offsettedIndexPath = IndexPath(row: indexPath.row, section: 0)
                
                self.tableViewDidSelect(tableView, indexPath: offsettedIndexPath)
            }
        } else {
            self.tableViewDidSelect(tableView, indexPath: indexPath)
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonProfile: UIBarButtonItem!
    @IBAction func pressProfile(_ sender: Any) {
        
    }
    
    @objc func pressActionTools(_ sender: Any) {
        UIAlertController(title: nil, message: "select an action", preferredStyle: .actionSheet)
            .addButton(title: "Duplicate") { [unowned self] (action) in
                guard let directoriesToCopy = self.directoriesForSelectedIndexPaths() else {
                    fatalError("action button should be disabled if no rows are selected")
                }
                
                self.directoryManager.duplicate(directories: directoriesToCopy, to: self.currentDirectory)
                self.viewModel.save()
                self.setEditing(false, animated: true)
            }
            .addButton(title: "Move to..") { [unowned self] (action) in
                guard let directoriesToMove = self.directoriesForSelectedIndexPaths() else {
                    fatalError("action button should be disabled if no rows are selected")
                }
                
                self.performSegue(withIdentifier: UIStoryboardSegue.showMove, sender: directoriesToMove)
            }
            .addButton(title: "Delete..", style: .destructive) { [unowned self] (action) in
                guard let directoriesToDelete = self.directoriesForSelectedIndexPaths() else {
                    fatalError("action button should be disabled if no rows are selected")
                }
                
                //TODO: allow undo deleted batch
                UIAlertController(title: "Delete Items", message: "are you sure you want to delete \(directoriesToDelete.count) items? This action cannot be undone", preferredStyle: .alert)
                    .addConfirmationButton(title: "Delete", style: .destructive, with: { [unowned self] (action) in
                        self.directoryManager.delete(directories: directoriesToDelete)
                        self.viewModel.save()
                        self.setEditing(false, animated: true)
                    })
                    .present(in: self)
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
                        case is Task.Type:
                            self.viewModel.addTask(with: newTitle)
                        case is Folder.Type:
                            self.viewModel.addFolder(with: newTitle)
                        default: break
                        }
                    }
                }
                .present(in: self)

        }
        
        UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            .addButton(title: "Task", with: { [unowned self] (action) in
                self.performSegue(withIdentifier: "show detailed task", sender: nil)
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
        
        let baseCell = UITaskTableViewCell.Types.baseCell
        tableView.register(baseCell.nib, forCellReuseIdentifier: baseCell.cellIdentifier)
        tableView.register(UITitleIconTableViewCell.nib(), forCellReuseIdentifier: UITitleIconTableViewCell.reusableIdentifier)
        
        //TODO: Dynamic Font, user preferences of which cell to display
        tableView.rowHeight = 44
        
        saveHandler = viewModel.save
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.backgroundColor = .backgroundColor
        
        //TODO: blury navigation item
        let navigationBar = navigationController!.navigationBar
        navigationBar.barTintColor = UIColor.backgroundColor
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
    }

}

// MARK: - MoveViewControllerDelegate

extension OrganizeTableViewController: MoveViewControllerDelegate {
    func move(viewController: MoveViewController, didMove items: [Directory], to destination: Directory?) {
        self.viewModel.save()
        self.setEditing(false, animated: true)
    }
}

// MARK: - UIStoryboardSegue

private extension UIStoryboardSegue {
    static let showChildDirectory = "show child directory"
    static let showDetailedTask = "show detailed task"
    static let showMove = "show move"
}
