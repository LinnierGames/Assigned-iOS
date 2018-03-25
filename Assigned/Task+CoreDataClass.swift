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
    
    convenience init(title: String = "Untitled Task", in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.title = title
    }
}

extension Directory {
    var task: Task {
        guard let taskInfo = self.info as! Task? else {
            fatalError("directory did not have its info set")
        }
        
        return taskInfo
    }
}

extension NSFetchedResultsController {
    @objc func task(at indexPath: IndexPath) -> Task {
        return self.object(at: indexPath) as! Task
    }
}
