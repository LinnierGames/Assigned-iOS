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
    
    var session: Session!
    
    lazy var context: NSManagedObjectContext = {
        guard let context = session.managedObjectContext else {
            fatalError("context was not set")
        }
        
        return context
    }()
}

extension SessionDetailedViewModel {
    
    var textStartDate: String {
        return String(date: session.startDate, formatterMap: .Day_oftheWeekFullName, ", ", .Month_shorthand, " ", .Day_ofTheMonthSingleDigit, " 'at' ", .Time_noPadding_am_pm)
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
