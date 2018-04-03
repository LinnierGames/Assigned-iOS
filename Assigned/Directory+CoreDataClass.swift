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
        let copiedDirectory = copiedInfo.directory
        
        copiedDirectory.parent = self.parent
        
        if let selfChildren = self.children {
            for aChild in selfChildren {
                let copiedChild = aChild.copying()
                copiedDirectory.addToChildren(copiedChild)
            }
        }
        
        return copiedDirectory
    }
}

extension NSFetchedResultsController {
    @objc func directory(at indexPath: IndexPath) -> Directory {
        return self.object(at: indexPath) as! Directory
    }
}
