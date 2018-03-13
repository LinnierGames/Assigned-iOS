//
//  UIAssignmentTableViewCell.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

@objc protocol UIAssignmentTableViewCellDelegate: class {
    @objc optional func assignment(cell: UIAssignmentTableViewCell, didPressCheckbox button: UIButton)
}

class UIAssignmentTableViewCell: UITableViewCell {
    
    private var projectImage = #imageLiteral(resourceName: "file-1")
    
    private var folderImage = #imageLiteral(resourceName: "folder-1")
    
    enum Types {
        static var baseCell = "assignment"
        static var notesCell = "assignment notes"
        static var extendedCell = "assignment extended"
    }
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDeadline: UILabel!
    @IBOutlet weak var labelTasks: UILabel!
    @IBOutlet weak var imagePriority: UIImageView!
    
    weak var delegate: UIAssignmentTableViewCellDelegate?
    
    // MARK: - RETURN VALUES
    
    private func image(for priority: Assignment.Priorities) -> UIImage? {
        switch priority {
        case .None:
            return nil
        case .Low:
            return UIImage(named: "priority-low")
        case .Medium:
            return UIImage(named: "priority-medium")
        case .High:
            return UIImage(named: "priority-high")
        }
    }
    
    // MARK: - VOID METHODS
    
    func configure(_ assignment: Assignment) {
        self.accessoryType = .none
        self.labelTitle.text = assignment.title
        if assignment.isCompleted {
            self.buttonCheckbox.setImage(UIImage.assignmentCheckboxCompleted, for: .normal)
        } else {
            self.buttonCheckbox.setImage(UIImage.assignmentCheckbox, for: .normal)
        }
        self.imagePriority.image = image(for: assignment.priority)
        if let deadline = assignment.deadline {
            self.labelDeadline.text = String(date: deadline, dateStyle: .short)
            
            //TODO: deadline formating
//            let durationTillDeadline = deadline.timeIntervalSinceNow
//            let unitsUntilDeadline = String(timeInterval: durationTillDeadline, options: .day)
//
//            self.labelDeadline.text = "in \(unitsUntilDeadline)"
        } else {
            self.labelDeadline.text = nil
        }
        //TODO: configure the assignment cell of all assignment properties
    }
    
    func configure(_ folder: Folder) {
        self.accessoryType = .disclosureIndicator
        self.labelTitle.text = folder.title
        self.buttonCheckbox.setImage(folderImage, for: .normal)
        //TODO: configure the assignment cell of all assignment properties
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonCheckbox: UIButton!
    @IBAction func pressCheckbox(_ sender: UIButton) {
        delegate?.assignment?(cell: self, didPressCheckbox: sender)
    }
    
    // MARK: - LIFE CYCLE

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension UINib {
    static func assignmentCells() -> UINib {
        return UINib(nibName: "UIAssignmentTableViewCell", bundle: Bundle.main)
    }
}

extension UIImage {
    static var assignmentCheckbox: UIImage {
        return #imageLiteral(resourceName: "checkbox")
    }
    
    static var assignmentCheckboxCompleted: UIImage {
        return #imageLiteral(resourceName: "checkbox-completed")
    }
    
    static var assignmentPriorityNone: UIImage {
        return #imageLiteral(resourceName: "priority-none")
    }
    
    static var assignmentPriorityLow: UIImage {
        return #imageLiteral(resourceName: "priority-low")
    }
    
    static var assignmentPriorityMedium: UIImage {
        return #imageLiteral(resourceName: "priority-medium")
    }
    
    static var assignmentPriorityHigh: UIImage {
        return #imageLiteral(resourceName: "priority-high")
    }
}
