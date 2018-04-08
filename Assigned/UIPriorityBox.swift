//
//  UIPriorityBox.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/13/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class UIPriorityBox: UIImageView {
    
    var priority: Task.Priorities = .None {
        didSet {
            switch priority {
            case .None:
                self.image = UIImage.taskPriorityNone
            case .Low:
                self.image = UIImage.taskPriorityLow
            case .Medium:
                self.image = UIImage.taskPriorityMedium
            case .High:
                self.image = UIImage.taskPriorityHigh
            }
        }
    }

    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE

}
