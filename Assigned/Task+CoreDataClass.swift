//
//  Task+CoreDataClass.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/10/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
    
    required public convenience init(title: String = "Untitled Task", in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.title = title
    }
    
    public func copying() -> Task {
        let copiedTask = type(of: self).init(title: self.title, in: self.managedObjectContext!)
        
        // Copy self's properties to copied
        copiedTask.assignment = self.assignment
        copiedTask.isCompleted = self.isCompleted
        
        return copiedTask
    }
}

extension NSFetchedResultsController {
    @objc func task(at indexPath: IndexPath) -> Task {
        return self.object(at: indexPath) as! Task
    }
}
