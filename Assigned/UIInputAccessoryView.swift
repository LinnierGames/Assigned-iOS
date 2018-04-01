//
//  UIInputAccessoryView.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/1/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class UIInputAccessoryView: UIView {
    
    enum AccessoryTypes {
        case Dismiss //right button is set to done with no caption
        case Custom //no presents are made
    }
    
    //TODO: use init vs a static func
//    init(accessoryType: AccessoryTypes) {
//
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // MARK: - RETURN VALUES
    
    /**
     - parameter accessoryType: add predefined button titles to the view
     
     - returns: a UIInputAccessoryView from its NIB
     */
    static func initialize(accessoryType: AccessoryTypes) -> UIInputAccessoryView {
        let bundle = Bundle(for: UIInputAccessoryView.self)
        let nibName = UIInputAccessoryView.description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIInputAccessoryView
        
        view.updateUI(for: accessoryType)
        
        return view
    }
    
    // MARK: - VOID METHODS
    
    /**
     Add a new Touch Up Inside event to the right button
     
     - parameter updateTitle: if you'd like to update the button title in this one function call
     along with adding a new action
     */
    func addActionToRightButton(action: @escaping (UIButton) -> (), updateTitle: String? = nil) {
        if let newTitle = updateTitle {
            rightButton.setTitleWithoutAnimation(newTitle, for: .normal)
        }
        self.rightButton.addTarget(for: .touchUpInside) { [weak self] in
            if let unwrappedSelf = self {
                action(unwrappedSelf.rightButton)
            }
        }
    }
    
    /**
     Add a new Touch Up Inside event to the left button
     
     - parameter updateTitle: if you'd like to update the button title in this one function call
     along with adding a new action
     */
    func addActionToLeftButton(action: @escaping (UIButton) -> (), updateTitle: String? = nil) {
        if let newTitle = updateTitle {
            leftButton.setTitleWithoutAnimation(newTitle, for: .normal)
        }
        self.leftButton.addTarget(for: .touchUpInside) { [weak self] in
            if let unwrappedSelf = self {
                action(unwrappedSelf.leftButton)
            }
        }
    }
    
    private func updateUI(for type: AccessoryTypes) {
        switch type {
        case .Dismiss:
            leftButton.setTitleWithoutAnimation(nil, for: .normal)
            labelCaption.text = nil
            rightButton.setTitleWithoutAnimation("Done", for: .normal)
        default:
            break
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    
    // MARK: - LIFE CYCLE

}
