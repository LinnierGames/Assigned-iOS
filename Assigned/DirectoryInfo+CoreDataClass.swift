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
    
    public override var description: String {
        return "Directory Info"
    }

}
