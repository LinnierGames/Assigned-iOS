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
        copiedSubtask.task = self.task
        copiedSubtask.isCompleted = self.isCompleted
        
        return copiedSubtask
    }
}

extension Set where Element: Subtask {
    
    /**
     Returns the sum of completed tasks
     
     - parameter <#bar#>: <#Consectetur adipisicing elit.#>
     
     - returns: <#Sed do eiusmod tempor.#>
     */
    var numberOfCompletedSubtasks: Int {
        return self.reduce(0, { (sum, aSubtask) -> Int in
            if aSubtask.isCompleted {
                return sum + 1
            } else {
                return sum
            }
        })
    }
}

extension NSFetchedResultsController {
    @objc func subtask(at indexPath: IndexPath) -> Subtask {
        return self.object(at: indexPath) as! Subtask
    }
}
