//
//  Session+CoreDataClass.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Session)
public class Session: NSManagedObject {
    
    convenience init(name: String,
                     date: Date,
                     duration: TimeInterval,
                     assignment: Assignment? = nil,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.name = name
        self.date = date
        self.duration = duration
        
        self.assignment = assignment
    }
}
