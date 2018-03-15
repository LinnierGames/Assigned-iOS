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
    @objc optional func task(cell: UITaskTableViewCell, didChangeTask task: Task, to newTitle: String?)
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
        
        static var Textfield = Info(id: "task textfield", nibTitle: "UITaskTableViewCell-TextField")
    }
    
    @IBOutlet weak var textfield: UITextField?
    
    @IBOutlet weak var labelTitle: UILabel?
    
    weak var delegate: (UITaskTableViewCellDelegate)?
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private(set) var task: Task?
    
    func configure(_ task: Task) {
        guard let textfield = self.textfield else {
            return assertionFailure("configured task without a label present")
        }
        
        buttonCheckbox.isChecked = task.isCompleted
        if task.isCompleted {
            textfield.attributedText = NSMutableAttributedString(strikedOut: task.title ?? "")
            textfield.textColor = .disabledGray
        } else {
            textfield.text = task.title
            textfield.textColor = .black
        }
        
        self.task = task
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard
            let task = self.task,
            task.isCompleted == false
            else {
                return
        }
        
        if selected {
            textfield?.isUserInteractionEnabled = true
            textfield?.becomeFirstResponder()
        } else {
            textfield?.isUserInteractionEnabled = false
            textfield?.resignFirstResponder()
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfield?.resignFirstResponder()
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let task = self.task {
            delegate?.task?(cell: self, didChangeTask: task, to: textField.text)
        }
    }
}
