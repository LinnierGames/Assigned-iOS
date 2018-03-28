//
//  SessionViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/20/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import CoreData

class SessionDetailedViewModel {
    
    private var sessionValue: Session!
    
    private var persistance = PersistenceStack.shared
    
    lazy var context: NSManagedObjectContext = {
        return persistance.viewContext
    }()
    
    var session: Session {
        get {
            if sessionValue == nil {
//                sessionValue = Session(name: <#T##String#>, date: <#T##Date#>, duration: <#T##TimeInterval#>, assignment: <#T##Assignment?#>, in: <#T##NSManagedObjectContext#>)
            }
            
            return sessionValue
        }
        set {
            sessionValue = newValue
        }
    }
}
