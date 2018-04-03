//
//  DirectoryInfo+CoreDataClass.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

@objc(DirectoryInfo)
public class DirectoryInfo: NSManagedObject {
    
    public required init(in context: NSManagedObjectContext) {
        
        // self's properties
        // ...
        
        super.init(entity: DirectoryInfo.entity(), insertInto: context)
    }
    
    var parentInfo: DirectoryInfo? {
        get {
            return self.parentDirectory?.info
        }
    }
    
    var parentDirectory: Directory? {
        set {
            self.directory.parent = newValue
        }
        get {
            return self.directory.parent
        }
    }
    
    var children: [DirectoryInfo] {
        guard let childrenDirectories = self.directory.children as! Set<Directory>? else {
            fatalError("could not cast children into a set of Directory")
        }
        
        let children = childrenDirectories.map { (directory) -> DirectoryInfo in
            return directory.info
        }
        
        return children
    }
    
    func copying() -> DirectoryInfo {
        let copied = type(of: self).init(in: self.managedObjectContext!)
        
        // Copy self's properties to copied
        copied.title = self.title
        
        return copied
    }
    
    public override var description: String {
        return "Directory Info"
    }

}
