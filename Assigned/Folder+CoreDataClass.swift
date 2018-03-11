//
//  Project+CoreDataClass.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import CoreData

@objc(Folder)
public class Folder: DirectoryInfo {
    
    convenience init(title: String, in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.title = title
    }
    
    public override var description: String {
        return "Folder"
    }
}

extension Directory {
    var folder: Folder {
        guard let folderInfo = self.info as! Folder? else {
            fatalError("directory did not have its info set")
        }
        
        return folderInfo
    }
}

extension NSFetchedResultsController {
    @objc func folder(at indexPath: IndexPath) -> Folder {
        return self.object(at: indexPath) as! Folder
    }
}
