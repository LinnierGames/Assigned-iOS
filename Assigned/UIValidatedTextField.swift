//
//  UIValidatedTextField.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/15/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
//  Usage: update the .textFielDelegate and do not use the .delegate from
//  UITextField

import UIKit

//@IBDesignable
class UIValidatedTextField: UITextField {
    
    typealias StringValidation = (String?) -> Bool
    
    enum Validations {
        static var cannotBeEmpty: StringValidation = { textValue in
            return textValue != nil && textValue != ""
        }
        
        //TODO: Numbers only, text only, etc
        static var all: StringValidation = { textValue in
            return true
        }
    }
    
    private(set) var textBeforeDidEnterEditing: String?
    
    /** If the textBeforeDidEnterEditing is equal to a blank string, defaultText
     will become the new textfield.text when result validation fails*/
    @IBInspectable
    var defaultText: String = ""
    
    var allowsResignFirstResponderOnReturn = true
    
    /** asks is the text, at the end of the editing, valid or return to the pervious text */
    var resultValidation: StringValidation = Validations.all
    
    /** asks is the inserted or deleted string valid, if not undo */
    var inputValidation: StringValidation = Validations.all
    
    @IBOutlet weak var textFieldDelegate: UITextFieldDelegate? {
        didSet {
            delegate = self
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE

}

extension UIValidatedTextField: UITextFieldDelegate {
    
    // MARK: - RETURN VALUES
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = textFieldDelegate?.textFieldShouldReturn?(textField)
        
        if allowsResignFirstResponderOnReturn {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textBeforeDidEnterEditing = textField.text
        
        textFieldDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return inputValidation(string)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // check result validation
        if resultValidation(textField.text) == false {
            
            // failed validation, revert to last text
            if let previousText = self.textBeforeDidEnterEditing {
                if previousText != "" {
                    textField.text = previousText
                } else {
                    textField.text = defaultText
                }
            } else {
                textField.text = defaultText
            }
        }
        
        textFieldDelegate?.textFieldDidEndEditing?(textField)
    }
}
