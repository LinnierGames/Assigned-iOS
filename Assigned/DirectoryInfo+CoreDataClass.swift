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
    
    var parent: DirectoryInfo? {
        return self.directory!.parent?.info!
    }
    
    var children: Set<DirectoryInfo> {
        guard let children = self.directory!.children as? Set<DirectoryInfo> else {
            fatalError("could not cast children into a set of DirectoryInfos")
        }
        
        return children
    }
    
    public override var description: String {
        return "Directory Info"
    }

}
