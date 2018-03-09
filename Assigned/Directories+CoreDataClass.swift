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

@objc(Directories)
public class Directory: NSManagedObject {
    
    convenience init(in context: NSManagedObjectContext) {
        self.init(context: context)
    }
    
    func createDirectory(for directoryInfo: DirectoryInfo, inside parent: Directory?, in context: NSManagedObjectContext) -> Directory {
        let newDirectory = Directory(in: context)
        newDirectory.info = directoryInfo
        newDirectory.parent = parent
        
        return newDirectory
    }
}
