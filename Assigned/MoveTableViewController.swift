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
        
        func childrenFolders(in directory: Folder, forCurrent depthValue: Int = 0) -> [DepthFolder] {
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
    
    
//    root
//        projects
//            assigned
//            ilogs
//            iwork
//        school
//            cs-3
//            mob-4
//            core
//        personal stuff
//            home
    
    
    // MARK: - RETURN VALUES
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foldersInDepth.count
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let depthFolder = foldersInDepth[indexPath.row]
        
        return depthFolder.depth
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let depthFolder = foldersInDepth[indexPath.row]
        let folder = depthFolder.folder
        
        cell.textLabel!.text = folder.title
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        
        /** fetch and filter the data then reload the tableView */
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let unwrappedSelf = self else { return }
            
            _ = unwrappedSelf.foldersInDepth
            
            DispatchQueue.main.async {
                unwrappedSelf.tableView.reloadData()
            }
        }
    }
    
    private func backgroundUpdateUI() {
        
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonConfirm: UIBarButtonItem!
    @IBAction func pressConfirm(_ sender: Any) {
        
    }
    
    @IBAction func pressCancel(_ sender: Any) {
        self.presentingViewController!.dismiss(animated: true)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        
        backgroundUpdateUI()
    }

}
