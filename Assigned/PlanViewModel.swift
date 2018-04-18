//
//  PlanViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import UIKit

protocol PlanViewModelDelegate: class {
    
}

class PlanViewModel {
    
    private let context = PersistenceStack.shared.viewContext
    
    private(set) lazy var calendar: CalendarStack = {
        do {
            return try CalendarStack(delegate: nil)
        } catch let err {
            fatalError(err.localizedDescription)
        }
    }()
    
    var defaultCalendarColor: UIColor {
        return UIColor(cgColor: calendar.defaultCalendar.cgColor).withAlphaComponent(0.35)
    }
}

extension PlanViewModel {
    
    func addSession(for task: Task, at date: Date) {
        let newSession = Session(
            title: nil,
            startDate: date,
            task: task, in: self.context)
        
        calendar.createEvent(for: newSession)
    }
}
