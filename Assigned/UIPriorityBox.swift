//
//  UIPriorityBox.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/13/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class UIPriorityBox: UIImageView {
    
    var priority: Assignment.Priorities = .None {
        didSet {
            switch priority {
            case .None:
                self.image = UIImage.assignmentPriorityNone
            case .Low:
                self.image = UIImage.assignmentPriorityLow
            case .Medium:
                self.image = UIImage.assignmentPriorityMedium
            case .High:
                self.image = UIImage.assignmentPriorityHigh
            }
        }
    }

    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE

}
