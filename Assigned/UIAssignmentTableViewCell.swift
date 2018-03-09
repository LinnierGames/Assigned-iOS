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
    
    // MARK: - VOID METHODS
    
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
