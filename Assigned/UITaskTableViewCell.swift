//
//  TaskTableViewCell.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/10/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class UITaskTableViewCell: UITableViewCell {
    
//    static var reuseableIdentifier = "task"
    @IBOutlet weak var textfield: UITextField?
    
    @IBOutlet weak var labelTitle: UILabel?
    enum Types {
        static var basic = "task"
        static var textfield = "task textfield"
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func configure(_ task: Task) {
        guard let labelTitle = self.labelTitle else {
            return assertionFailure("configured task without a label present")
        }
        
        labelTitle.text = task.title
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var labelCheckbox: UIButton!
    @IBAction func pressCheckbox(_ sender: Any) {
        
    }
    
    // MARK: - LIFE CYCLE

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UITaskTableViewCell: UITextFieldDelegate {
    
}

extension UINib {
    static func assignmentTaskCells() -> UINib {
        return UINib(nibName: "UITaskTableViewCell", bundle: Bundle.main)
    }
}
