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
    
    func addTask(with title: String) {
        let newTask = Task(title: title, effort: 0, parent: self.currentDirectory, in: managedObjectContext)
        self.addTask(newTask)
    }
    
    func addTask(_ task: Task) {
        self.save()
    }
    
    func addFolder(with title: String) {
        let newFolder = Folder(title: title, parent: self.currentDirectory, in: managedObjectContext)
        self.addFolder(newFolder)
    }
    
    func addFolder(_ folder: Folder) {
        self.save()
    }
    
    func save() {
        persistance.saveContext()
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}
