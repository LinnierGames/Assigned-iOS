//
//  Subtask+CoreDataClass.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/10/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Subtask)
public class Subtask: NSManagedObject {
    
    required public convenience init(title: String = "Untitled Subtask", in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.title = title
    }
    
    public func copying() -> Subtask {
        let copiedSubtask = type(of: self).init(title: self.title, in: self.managedObjectContext!)
        
        // Copy self's properties to copied
        copiedSubtask.assignment = self.assignment
        copiedSubtask.isCompleted = self.isCompleted
        
        return copiedSubtask
    }
}

extension NSFetchedResultsController {
    @objc func subtask(at indexPath: IndexPath) -> Subtask {
        return self.object(at: indexPath) as! Subtask
    }
}
