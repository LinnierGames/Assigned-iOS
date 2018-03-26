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

@objc protocol MoveViewControllerDelegate: class {
    @objc optional func move(viewController: MoveViewController, didMove item: DirectoryInfo, to destination: DirectoryInfo?)
}

class MoveViewController: UITableViewController {
    
    /** this is the item that will have its parent updated to */
    var item: DirectoryInfo!
    
    weak var delegate: MoveViewControllerDelegate?
    
    /** take the context from the given item */
    private var context: NSManagedObjectContext! {
        return item.managedObjectContext
    }
    
    private struct DepthFolder {
        let folder: Folder
        let depth: Int
    }
    
    private lazy var foldersInDepth: [DepthFolder] = {
        
        //TODO: move assignments into projects (use DirectoryInfo instead of Folder)
        let fetch: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetch.predicate = NSPredicate(format: "directory.parent == nil")
        
        guard let rootFolders = try? context.fetch(fetch) else {
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
        cell.detailTextLabel!.text = nil
        
        // Root destination
        if indexPath.row == 0 {
            cell.textLabel!.text = "Top Directory"
            if item.parentDirectory == nil {
                cell.detailTextLabel!.text = "current folder"
            }
            
        // All folders
        } else {
            let depthFolder = foldersInDepth[indexPath.row - 1]
            let folder = depthFolder.folder
            
            cell.textLabel!.text = folder.title
            if item.parentDirectory?.objectID == folder.directory!.objectID {
                cell.detailTextLabel!.text = "current folder"
            }
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        
        /** fetch and filter the data then reload the tableView */
        _ = self.foldersInDepth
        self.tableView.reloadData()
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // enable the confirm button
        if let indexPaths = tableView.indexPathForSelectedRow, indexPaths.count > 0 {
            buttonConfirm.isEnabled = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        // disable the confirm button
        if tableView.indexPathForSelectedRow?.count == 0 {
            buttonConfirm.isEnabled = false
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonConfirm: UIBarButtonItem!
    @IBAction func pressConfirm(_ sender: Any) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            fatalError("this button should not be enabled if no row is selected")
        }
        
        let newDestination: Directory?
        
        // set parent to root directory
        if selectedIndexPath.row == 0 {
            newDestination = nil
            
        // set parent to selected row
        } else {
            let selectedRow = selectedIndexPath.row - 1
            let selectedDestination = foldersInDepth[selectedRow].folder
            
            newDestination = selectedDestination.directory!
        }
        item.parentDirectory = newDestination
        
        self.delegate?.move?(viewController: self, didMove: item, to: newDestination?.info!)
        self.presentingViewController!.dismiss(animated: true)
    }
    
    @IBAction func pressCancel(_ sender: Any) {
        self.presentingViewController!.dismiss(animated: true)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard item != nil else {
            return assertionFailure("item was not set when this view was presented")
        }
        
        updateUI()
    }
}
