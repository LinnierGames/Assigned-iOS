//
//  Folder+CoreDataClass.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import CoreData

@objc(Folder)
public class Folder: DirectoryInfo, NSCopying {
    
    convenience init(title: String, in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.title = title
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        var copied = super.copy() as! Folder
        
        
        var parent = DirectoryInfo()
        var child: Folder = parent as! Folder
    }
    
    public override var description: String {
        return "Folder"
    }
}

extension Directory {
    var folder: Folder {
        return self.info as! Folder
    }
    
    var isFolder: Bool {
        return self.info is Folder
    }
}

extension NSFetchedResultsController {
    @objc func folder(at indexPath: IndexPath) -> Folder {
        return self.object(at: indexPath) as! Folder
    }
}
