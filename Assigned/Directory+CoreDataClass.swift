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
        let copiedInfo = self.info.copying()
        let copied = copiedInfo.directory
        
        copied.parent = self.parent
        //TODO: copy children
        //        copied.children = self.children?.copy()
        
        return copied
    }
}

extension NSFetchedResultsController {
    @objc func directory(at indexPath: IndexPath) -> Directory {
        return self.object(at: indexPath) as! Directory
    }
}
