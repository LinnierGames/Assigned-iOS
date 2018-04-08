//
//  UISubtaskTableViewCell.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/10/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

@objc protocol UISubtaskTableViewCellDelegate: class {
    @objc optional func subtask(cell: UISubtaskTableViewCell, didTapCheckBox newState: Bool)
    @objc optional func subtask(cell: UISubtaskTableViewCell, didChangeSubtask subtask: Subtask, to newTitle: String)
}

class UISubtaskTableViewCell: UITableViewCell {
    
    enum Types {
        struct Info {
            var cellIdentifier: String
            var nib: UINib
            
            init(id: String, nibTitle: String) {
                cellIdentifier = id
                nib = UINib(nibName: nibTitle, bundle: Bundle.main)
            }
        }
        
        static var Basic = Info(id: "subtask", nibTitle: "UISubtaskTableViewCell")
        
        static var Textfield = Info(id: "subtask textfield", nibTitle: "UISubtaskTableViewCell-TextField")
    }
    
    @IBOutlet weak var textfield: UIValidatedTextField? {
        didSet {
            textfield?.textFieldDelegate = self
            textfield?.resultValidation = UIValidatedTextField.Validations.cannotBeEmpty
            textfield?.enablesReturnKeyAutomatically = true
        }
    }
    
    @IBOutlet weak var labelTitle: UILabel?
    
    weak var delegate: (UISubtaskTableViewCellDelegate)?
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private(set) var subtask: Subtask?
    
    func configure(_ subtask: Subtask) {
        guard let textfield = self.textfield else {
            return assertionFailure("configured subtask without a label present")
        }
        
        buttonCheckbox.isChecked = subtask.isCompleted
        if subtask.isCompleted {
            textfield.attributedText = NSMutableAttributedString(strikedOut: subtask.title)
            textfield.textColor = .disabledGray
        } else {
            textfield.text = subtask.title
            textfield.textColor = .black
        }
        
        self.subtask = subtask
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard
            let subtask = self.subtask,
            subtask.isCompleted == false
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
        
        textfield?.resignFirstResponder()
        
        delegate?.subtask?(cell: self, didTapCheckBox: buttonCheckbox.isChecked)
    }
    
    // MARK: - LIFE CYCLE
    
}

extension UISubtaskTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        // if the button is already checked, return false
        return buttonCheckbox.isChecked.inverse
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // check if the cell was configured with a subtask
        guard let subtask = self.subtask else { return }
        
        textField.placeholder = subtask.title
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // check if the cell was configured with a subtask
        guard let subtask = self.subtask else { return }
        
        delegate?.subtask?(cell: self, didChangeSubtask: subtask, to: textField.text ?? "")
    }
}
