//
//  Directories+CoreDataClass.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Directory)
public class Directory: NSManagedObject {
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required public init(in context: NSManagedObjectContext) {
        
        // self's properties
        // ...

        super.init(entity: type(of: self).entity(), insertInto: context)
    }
    
    func copying() -> Directory {
        let copied = type(of: self).init(in: self.managedObjectContext!)
        
        // Copy self's properties to copied
        copied.info = self.info.copying()
        
        return copied
    }
}

extension NSFetchedResultsController {
    @objc func directory(at indexPath: IndexPath) -> Directory {
        return self.object(at: indexPath) as! Directory
    }
}
