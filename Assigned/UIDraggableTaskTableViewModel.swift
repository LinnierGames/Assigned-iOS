//
//  UIDraggableTaskTableViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/14/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import UIKit.UIFont

struct UIDraggableTaskTableViewModel {
    
    weak var task: Task!
    
    var deadlineText: NSAttributedString {
        if let deadline = task.deadline {
            if deadline < Date() {
                let deadlineDate = String(date: deadline, dateStyle: .short, timeStyle: .short)
                let deadlineText = "Overdue: \(deadlineDate)"
                let attributes: [NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10, weight: .bold)
                ]
                let attributedString = NSMutableAttributedString(
                    attributedString:
                    
                    NSAttributedString(
                        string: deadlineText,
                        for: { (aCharacter) -> (Bool) in
                            return String(aCharacter).rangeOfCharacter(from: .letters) != nil
                    },
                        with: attributes)
                )
                attributedString.addAttribute(
                    NSAttributedStringKey.foregroundColor,
                    value: UIColor.red,
                    range: deadlineText.rangeOfCharacters
                )
                
                return attributedString
            } else {
                if deadline.isToday {
                    let deadlineText = String(date: deadline, formatterMap: "'Today at' ", .Time_noPadding_am_pm)
                    
                    return NSAttributedString(string: deadlineText)
                } else if deadline.isTomorrow {
                    let deadlineText = String(date: deadline, formatterMap: "'Tomorrow at' ", .Time_noPadding_am_pm)
                    
                    return NSAttributedString(string: deadlineText)
                } else {
                    
                    // same week - Sunday 21 at 2:02 pm
                    if deadline.isSame(as: Date(), compareBy: { $0.weekOfYear! == $1.weekOfYear! }) {
                        let deadlineText = String(date: deadline, formatterMap: .Day_ofTheWeekFullName, " ", .Day_ofTheMonthNoPadding, " 'at' ", .Time_noPadding_am_pm)
                        
                        return NSAttributedString(string: deadlineText)
                        
                    // not today, tomorrow or the same week - Sun, Apr 21 at 2:02 pm
                    } else {
                        let deadlineText = String(date: deadline, formatterMap: .Day_ofTheWeekFullName, ", ", .Month_shorthand, " ", .Day_ofTheMonthNoPadding, " 'at' ", .Time_noPadding_am_pm)
                        
                        return NSAttributedString(string: deadlineText)
                    }
                }
            }
        } else {
            return NSAttributedString(string: "")
        }
    }
}
