//
//  TaskTableViewCell.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/10/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

@objc protocol UITaskTableViewCellDelegate: class {
    @objc optional func task(cell: UITaskTableViewCell, didTapCheckBox newState: Bool)
}

class UITaskTableViewCell: UITableViewCell {
    
    enum Types {
        struct Info {
            var cellIdentifier: String
            var nib: UINib
            
            init(id: String, nibTitle: String) {
                cellIdentifier = id
                nib = UINib(nibName: nibTitle, bundle: Bundle.main)
            }
        }
        
        static var Basic = Info(id: "task", nibTitle: "UITaskTableViewCell")
        
        //TODO: layout textfield cell
//        static var Textfield = Info(id: "task textfield", nibTitle: "UITaskTableViewCell-TextField")
    }
    
    @IBOutlet weak var textfield: UITextField?
    
    @IBOutlet weak var labelTitle: UILabel?
    
    weak var delegate: UITaskTableViewCellDelegate?
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func configure(_ task: Task) {
        guard let labelTitle = self.labelTitle else {
            return assertionFailure("configured task without a label present")
        }
        
        buttonCheckbox.isChecked = task.isCompleted
        if task.isCompleted {
            labelTitle.attributedText = NSMutableAttributedString(strikedOut: task.title ?? "")
            labelTitle.textColor = .disabledGray
        } else {
            labelTitle.text = task.title
            labelTitle.textColor = .black
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonCheckbox: UICheckbox!
    @IBAction func pressCheckbox(_ sender: Any) {
        buttonCheckbox.isChecked.invert()
        
        delegate?.task?(cell: self, didTapCheckBox: buttonCheckbox.isChecked)
    }
    
    // MARK: - LIFE CYCLE
    
}

extension UITaskTableViewCell: UITextFieldDelegate {
    
}

extension UINib {
    static func assignmentTaskCell() -> UINib {
        return UINib(nibName: "UITaskTableViewCell", bundle: Bundle.main)
    }
}
