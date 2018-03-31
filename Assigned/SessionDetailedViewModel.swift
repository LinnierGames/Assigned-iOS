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
    
    lazy var context: NSManagedObjectContext = {
        guard let context = session.managedObjectContext else {
            fatalError("context was not set")
        }
        
        return context
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

extension SessionDetailedViewModel {
    
    var textStartDate: String {
        return String(date: session.startDate, dateStyle: .full, timeStyle: .short)
    }
    
    var textEndDate: String {
        let endDate = session.startDate.addingTimeInterval(session.durationValue)
        let text: String
        
        //only print the time
        if session.startDate.isSameDay(as: endDate) {
            text = String(date: endDate, dateStyle: .none, timeStyle: .short)
            
            //also print the day along with the time
        } else {
            text = String(date: endDate, dateStyle: .full, timeStyle: .short)
        }
        
        return text
    }
    
    var textDuration: String {
        return String(timeInterval: session.durationValue)
    }
}
