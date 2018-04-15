//
//  UITouchBarrier.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/14/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

@IBDesignable
class UITouchBarrier: UIImageView {
    
    @IBInspectable
    var enableTouchBarrier: Bool = false {
        didSet {
            if enableTouchBarrier {
                self.isUserInteractionEnabled = true
                UIView.animate(withDuration: TimeInterval.transitionAnimationDuration) { [unowned self] in
                    self.backgroundColor = .lowDarkTransparency
                }
            } else {
                self.isUserInteractionEnabled = false
                UIView.animate(withDuration: TimeInterval.transitionAnimationDuration) { [unowned self] in
                    self.backgroundColor = .clear
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}
