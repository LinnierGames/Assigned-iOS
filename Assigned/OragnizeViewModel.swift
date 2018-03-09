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
    
    var managedObjectContext: NSManagedObjectContext {
        return persistance.viewContext
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func addAssignment(with title: String) {
        let assignment = Assignment(title: title, effort: 0, in: managedObjectContext)
        
        self.save()
    }
    
    func addAssignment(_ assignment: Assignment) {
        
    }
    
    func save() {
        persistance.saveContext()
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}
