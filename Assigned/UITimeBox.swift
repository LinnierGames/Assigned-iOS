//
//  UITimeBox.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/15/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class UITimeBox: UIView {
    
    /** legnth in seconds */
    public var duration: TimeInterval = 0.0 { didSet { self.updateUI() }}
    
    public var calendarUnits: [Calendar.Component] = [.weekday, .day, .hour, .minute]
    
    let digits: (Character) -> (Bool) = { aCharacter in
        return Int(String(aCharacter)) != nil
    }
    
    lazy var digitsAttributes: [NSAttributedStringKey: Any] = {
        let currentLabelSize = self.label.font.pointSize
        
        return [
            //TODO: dynamic font
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: currentLabelSize * 1.75, weight: UIFont.Weight.bold)
        ]
    }()

    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        let options = String.TimeIntervalOptions(
            units: calendarUnits,
            unitWindowSize: 2,
            textInterpolation: { (count, descriptor) -> (String) in
                return "\(count)\(descriptor.short!)"
            }
        )
        
        let textDuration = String(timeInterval: duration, options: options)
        label.attributedText = NSAttributedString(string: textDuration, for: digits, with: digitsAttributes)
//        if combinedTextDuration.count == 2 {
//            let durationNumber = combinedTextDuration[0]
//            let unitText = combinedTextDuration[1]
//
//            labelMajor.text = String(durationNumber)
//            labelMinor.text = String(unitText)
//        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var labelCaption: UILabel!
    
    // MARK: - LIFE CYCLE
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateUI()
    }

}
