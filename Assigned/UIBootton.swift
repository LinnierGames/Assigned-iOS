//
//  UIBootton.swift
//  temp
//
//  Created by Erick Sanchez on 5/6/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

extension UIView {
    func transformToSquare() {
        let viewCenter = self.center
        let edgeLength = max(self.frame.width, self.frame.height)
        self.frame = CGRect(x: 0, y: 0, width: edgeLength, height: edgeLength)
        self.center = viewCenter
    }
}

struct UIDesignable {
    private var view: UIView
    
    private init(view: UIView) {
        self.view = view
    }
    
    // MARK: - Public Inits
    
    @discardableResult
    static func applyCircle(to view: UIView) -> UIDesignable {
        view.transformToSquare()
        
        let designable = UIDesignable(view: view)
        let radius = view.bounds.height / 2.0
        designable.cornerRadius(radius)
        
        return designable
    }
    
    // MARK: - Methods
    
    @discardableResult
    func color(_ color: UIColor?) -> UIDesignable {
        self.view.layer.backgroundColor = color?.cgColor
        
        return self
    }
    
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> UIDesignable {
        self.view.layer.cornerRadius = radius
        
        return self
    }
}

@IBDesignable
class UIBootton: UIButton {
    
    @IBOutlet weak var badge: UILabel?
    
    @IBInspectable
    var styledBadge: Bool = false
    
    @IBInspectable
    var value: Int = 0
    
    static var cornerRadius: CGFloat = 4.0
    
    static var outlineWidth: CGFloat = 1.0
    
    static var outlineColor: UIColor = .buttonTint
    
    @IBInspectable
    var roundedOutline: Bool = false {
        didSet {
            if roundedOutline == true {
                outlined = true
                cornerRadius = UIBootton.cornerRadius
                outlineColor = UIBootton.outlineColor
                margin = CGSize(width: 12.0, height: 8.0)
            } else {
                outlined = false
                cornerRadius = 0.0
                outlineColor = nil
                margin = CGSize.zero
            }
        }
    }
    
    @IBInspectable
    var corners: CGFloat = 0.0 {
        didSet {
            cornerRadius = corners
        }
    }
    
    var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
    @IBInspectable
    var margin: CGSize = .zero {
        didSet {
            setMargin(
                top: margin.height,
                left: margin.width,
                bottom: margin.height,
                right: margin.width
            )
        }
    }
    
    func setMargin(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        contentEdgeInsets = UIEdgeInsets(
            top: top,
            left: left,
            bottom: bottom,
            right: right
        )
    }
    
    @IBInspectable
    var outlined: Bool = false {
        didSet {
            if outlined == true {
                if self.outlineWidth == 0.0 {
                    outlineWidth = UIBootton.outlineWidth
                }
            } else {
                outlineWidth = 0.0
            }
        }
    }
    
    @IBInspectable
    var outlineWidth: CGFloat = 0.0 {
        didSet {
            borderWidth = outlineWidth
        }
    }
    
    var borderWidth: CGFloat {
        set {
            self.layer.borderWidth = newValue
        }
        get {
            return self.layer.borderWidth
        }
    }
    
    @IBInspectable
    var outlineColor: UIColor? = UIBootton.outlineColor {
        didSet {
            self.layer.borderColor = outlineColor?.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let badge = self.badge, self.styledBadge {
            UIDesignable.applyCircle(to: badge)
                .color(.red)
        }
        
        if let badge = self.badge {
            badge.text = String(value)
        }
    }
}
