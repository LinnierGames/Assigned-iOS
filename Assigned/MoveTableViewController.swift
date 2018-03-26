//
//  MoveTableViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/23/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//  Will print all folders in an outline form style and
//  update the parent of the item given to move

import UIKit
import CoreData

class MoveTableViewController: UITableViewController {
    
    /** this is the item that will have its parent updated to */
    var item: DirectoryInfo!
    
//    private var persistence = PersistenceStack.shared
    
//    private lazy var rootFolders: [Folder] = {
//    }()
    
    private struct DepthFolder {
        let folder: Folder
        let depth: Int
    }
    
    private lazy var foldersInDepth: [DepthFolder] = {
        
        //TODO: move assignments into projects (use DirectoryInfo instead of Folder)
        let fetch: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetch.predicate = NSPredicate(format: "directory.parent == nil")
        
        guard let rootFolders = try? PersistenceStack.shared.viewContext.fetch(fetch) else {
            fatalError("could not fetch folders")
        }
        
        func childrenFolders(in directory: Folder, forCurrent depthValue: Int = 1) -> [DepthFolder] {
            var folders = [DepthFolder(folder: directory, depth: depthValue)]
            
            for aChild in directory.children {
                if let folder = aChild as? Folder {
                    folders += childrenFolders(in: folder, forCurrent: depthValue + 1)
                }
            }
            
            return folders
        }
        
        var collectionOfFolders: [DepthFolder] = []
        for aFolder in rootFolders {
            collectionOfFolders += childrenFolders(in: aFolder)
        }
        
        return collectionOfFolders
    }()
    
    // MARK: - RETURN VALUES
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foldersInDepth.count + 1 // Root destination is handled by the table view, not the data
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.row == 0 {
            return 0
        } else {
            let depthFolder = foldersInDepth[indexPath.row - 1]
            
            return depthFolder.depth
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Root destination
        if indexPath.row == 0 {
            cell.textLabel!.text = "Top Directory"
        } else {
            let depthFolder = foldersInDepth[indexPath.row - 1]
            let folder = depthFolder.folder
            
            cell.textLabel!.text = folder.title
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        
        /** fetch and filter the data then reload the tableView */
        _ = self.foldersInDepth
        self.tableView.reloadData()
    }
    
    private func backgroundUpdateUI() {
        
    }
    
    override func didChange(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, forKey key: String) {
        switch key {
        case "indexPathForSelectedRow":
            
            // enable the confirm button
            if let indexPaths = tableView.indexPathForSelectedRow, indexPaths.count > 0 {
                buttonConfirm.isEnabled = false
                
            // disable
            } else {
                buttonConfirm.isEnabled = false
            }
        default:
            break
        }
    }
    
    // MARK: Table View Delegate
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonConfirm: UIBarButtonItem!
    @IBAction func pressConfirm(_ sender: Any) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            fatalError("this button should not be enabled if no row is selected")
        }
        
        // set parent to root directory
        if selectedIndexPath.row == 0 {
            item.parentDirectory = nil
            
        // set parent to selected row
        } else {
            let selectedRow = selectedIndexPath.row - 1
            let selectedDestination = foldersInDepth[selectedRow].folder
            
            item.parentDirectory = selectedDestination.directory!
        }
        
        self.presentingViewController!.dismiss(animated: true)
    }
    
    @IBAction func pressCancel(_ sender: Any) {
        self.presentingViewController!.dismiss(animated: true)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addObserver(self, forKeyPath: "indexPathForSelectedRow", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard item != nil else {
            return assertionFailure("item was not set when this view was presented")
        }
        
        updateUI()
        
        backgroundUpdateUI()
    }

}
