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
    
    required public init(in context: NSManagedObjectContext) {
        
        // self's properties
        // ...

        super.init(entity: Directory.entity(), insertInto: context)
    }
    
//    convenience init(copy directory: Directory, in contextValue: NSManagedObjectContext? = nil) {
//        let context: NSManagedObjectContext
//        if let newContext = contextValue {
//            context = newContext
//        } else {
//            context = directory.managedObjectContext!
//        }
//
//
//        self.init(for: directory.info.copy() as! DirectoryInfo, parent: directory.parent, in: context)
//
////        if let folder = directory.info as? Folder {
////            self.init(for: folder, parent: directory.parent, in: context)
////        } else if let assignment = directory.info as? Assignment {
////            self.init(for: assignment, parent: directory.parent, in: context)
////        } else {
////            self.init(for: directory.info, parent: directory.parent, in: context)
////        }
//    }
    
    convenience init(for directoryInfo: DirectoryInfo, parent: Directory?, in context: NSManagedObjectContext) {
        self.init(in: context)
        self.info = directoryInfo
        self.parent = parent
    }
    
    func copying() -> Directory {
        let copied = type(of: self).init(in: self.managedObjectContext!)
        
        // Copy self's properties to copied
        copied.info = self.info.copying()
        
        return copied
    }
    
    //TODO: remove "init" helper
    static func createDirectory(for directoryInfo: DirectoryInfo, parent: Directory?, in context: NSManagedObjectContext) -> Directory {
        let newDirectory = Directory(in: context)
        newDirectory.info = directoryInfo
        newDirectory.parent = parent
        
        return newDirectory
    }
}

extension NSFetchedResultsController {
    @objc func directory(at indexPath: IndexPath) -> Directory {
        return self.object(at: indexPath) as! Directory
    }
}
