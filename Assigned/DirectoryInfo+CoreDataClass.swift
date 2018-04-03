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
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required public init(title: String, parent: Directory?, in context: NSManagedObjectContext) {
        super.init(entity: type(of: self).entity(), insertInto: context)
        
        // self's properties
        self.title = title
        self.directory = Directory(in: context)
        self.parentDirectory = parent
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
        let copied = type(of: self).init(title: self.title, parent: self.parentDirectory, in: self.managedObjectContext!)
        
        // Copy self's properties to copied
        // ...
        
        return copied
    }
    
    public override var description: String {
        return "Directory Info"
    }

}
