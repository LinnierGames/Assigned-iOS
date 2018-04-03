//
//  Directory+CoreDataProperties.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/30/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

extension Directory {
    enum StringKeys {
        static let parent = "parent"
        static let children = "children"
        static let info = "info"
    }
}

extension Directory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Directory> {
        return NSFetchRequest<Directory>(entityName: "Directories")
    }

    @NSManaged public var children: Set<Directory>?
    @NSManaged public var info: DirectoryInfo
    @NSManaged public var parent: Directory?

}

// MARK: Generated accessors for children
extension Directory {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: Directory)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: Directory)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}
