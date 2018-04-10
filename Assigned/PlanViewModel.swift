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
    
}
