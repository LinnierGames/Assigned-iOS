//
//  Folder+CoreDataProperties.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/31/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData


extension Folder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folders")
    }
}
