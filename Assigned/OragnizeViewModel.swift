//
//  OragnizeViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import CoreData

struct OrganizeViewModel {
    
    private var persistance = PersistenceStack.shared
    
    var currentDirectory: Directory? = nil
    
    var managedObjectContext: NSManagedObjectContext {
        return persistance.viewContext
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func addAssignment(with title: String) {
        let newAssignment = Assignment.createAssignment(title: title, effort: 0, in: managedObjectContext)
        self.addAssignment(newAssignment)
    }
    
    func addAssignment(_ assignment: Assignment) {
        _ = Directory.createDirectory(for: assignment, parent: self.currentDirectory, in: managedObjectContext)
        self.save()
    }
    
    func addFolder(with title: String) {
        let newFolder = Folder(title: title, in: managedObjectContext)
        self.addFolder(newFolder)
    }
    
    func addFolder(_ folder: Folder) {
        _ = Directory.createDirectory(for: folder, parent: self.currentDirectory, in: managedObjectContext)
        self.save()
    }
    
    func save() {
        persistance.saveContext()
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}
