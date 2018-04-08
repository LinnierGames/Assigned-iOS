//
//  UITaskTableViewCell.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

@objc protocol UITaskTableViewCellDelegate: class {
    @objc optional func task(cell: UITaskTableViewCell, didPressCheckbox button: UIButton)
}

class UITaskTableViewCell: UITableViewCell {
    
    private var projectImage = #imageLiteral(resourceName: "file-1")
    
    private var folderImage = #imageLiteral(resourceName: "folder-1")
    
    enum Types {
        struct Info {
            var cellIdentifier: String
            var nib: UINib
            
            init(id: String, nibTitle: String) {
                cellIdentifier = id
                nib = UINib(nibName: nibTitle, bundle: Bundle.main)
            }
        }
        
        static var baseCell = Info(id: "task", nibTitle: "UITaskTableViewCell")
        //TODO: Layout notes/extended cells in nibs
//        static var notesCell = Info(id: "task notes", nibTitle: "UITaskTableViewCell-Notes")
//        static var extendedCell = Info(id: "task extended", nibTitle: "UITaskTableViewCell-Extended")
    }
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDeadline: UILabel!
    @IBOutlet weak var labelTasks: UILabel!
    @IBOutlet weak var imagePriority: UIPriorityBox!
    
    weak var delegate: UITaskTableViewCellDelegate?
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func configure(_ task: Task) {
        self.accessoryType = .none
        self.labelTitle.text = task.title
        if task.isCompleted {
            self.buttonCheckbox.setImage(UIImage.taskCheckboxCompleted, for: .normal)
        } else {
            self.buttonCheckbox.setImage(UIImage.taskCheckbox, for: .normal)
        }
        self.imagePriority.priority = task.priority
        if let deadline = task.deadline {
            self.labelDeadline.text = String(date: deadline, dateStyle: .short)
            
            //TODO: deadline formating
//            let durationTillDeadline = deadline.timeIntervalSinceNow
//            let unitsUntilDeadline = String(timeInterval: durationTillDeadline, options: .day)
//
//            self.labelDeadline.text = "in \(unitsUntilDeadline)"
        } else {
            self.labelDeadline.text = nil
        }
        //TODO: configure the task cell of all task properties
    }
    
    func configure(_ folder: Folder) {
        self.accessoryType = .disclosureIndicator
        self.labelTitle.text = folder.title
        self.buttonCheckbox.setImage(folderImage, for: .normal)
        //TODO: configure the task cell of all task properties
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonCheckbox: UIButton!
    @IBAction func pressCheckbox(_ sender: UIButton) {
        delegate?.task?(cell: self, didPressCheckbox: sender)
    }
    
    // MARK: - LIFE CYCLE

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension UIImage {
    static var taskCheckbox: UIImage {
        return #imageLiteral(resourceName: "checkbox")
    }
    
    static var taskCheckboxCompleted: UIImage {
        return #imageLiteral(resourceName: "checkbox-completed")
    }
    
    static var taskPriorityNone: UIImage {
        return #imageLiteral(resourceName: "priority-none")
    }
    
    static var taskPriorityLow: UIImage {
        return #imageLiteral(resourceName: "priority-low")
    }
    
    static var taskPriorityMedium: UIImage {
        return #imageLiteral(resourceName: "priority-medium")
    }
    
    static var taskPriorityHigh: UIImage {
        return #imageLiteral(resourceName: "priority-high")
    }
}
