//
//  UIInputAccessoryView.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/1/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

//TODO: modular accessory view
class UIInputAccessoryView: UIView {
    
    enum AccessoryTypes {
        case Dismiss // right button is set to done with no caption
        case Custom // no presents are made
    }
    
    static func initialize(accessoryType: AccessoryTypes) -> UIInputAccessoryView {
        let bundle = Bundle(for: UIInputAccessoryView.self)
        let nibName = UIInputAccessoryView.description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIInputAccessoryView
        
        view.updateUI(for: accessoryType)
        
        return view
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
    
    // MARK: - VOID METHODS
    
    private func updateUI(for type: AccessoryTypes) {
        switch type {
        case .Dismiss:
            buttonLeft.setTitleWithoutAnimation(nil, for: .normal)
            labelCaption.text = nil
            rightButton.setTitleWithoutAnimation("Done", for: .normal)
        default:
            break
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonLeft: UIButton!
    @IBAction func pressLeftButton(_ sender: Any) {

    }
    
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBAction func pressRightButton(_ sender: Any) {
        
    }
    
    // MARK: - LIFE CYCLE

}
