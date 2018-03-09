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
    
    convenience init(in context: NSManagedObjectContext) {
        self.init(context: context)
    }
    
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
