//
//  DirectoryInfo+CoreDataProperties.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/30/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

extension DirectoryInfo {
    enum StringKeys {
        static let title = "title"
        static let directory = "directory"
    }
}


extension DirectoryInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DirectoryInfo> {
        return NSFetchRequest<DirectoryInfo>(entityName: "DirectoryInfos")
    }

    @NSManaged public var title: String
    @NSManaged public var directory: Directory

}
