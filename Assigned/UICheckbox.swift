//
//  UICheckbox.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/13/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

//@IBDesignable
class UICheckbox: UIButton {
    
    @IBInspectable
    var uncheckedImage: UIImage = UIImage.assignmentCheckbox
    
    @IBInspectable
    var checkedImage: UIImage = UIImage.assignmentCheckboxCompleted
    
    var isChecked: Bool = false {
        didSet {
            if isChecked {
                self.setImage(checkedImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE

}
