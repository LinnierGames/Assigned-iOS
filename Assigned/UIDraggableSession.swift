//
//  UIDraggableSession.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class UIDraggableSession: UIView {
    
    @IBOutlet var contentView: UIView!
    
    init(task: Task, withCopied frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        initialize(task: task)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize(task: nil)
    }
    
    func initialize(task: Task? = nil, withCopied frame: CGRect = CGRect.zero) {
        _ = Bundle.main.loadNibNamed(UINib.classNib, owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        
        self.layer.cornerRadius = 4.0
        
        if let task = task {
            self.updateUI(for: task)
        }
    }
    
//    init(task: Task, withCopied frame: CGRect = CGRect.zero) {
//        super.init(frame: frame)
//        self = nib.load
//        Bundle.main.loadNibNamed(UINib.classNib, owner: self, options: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI(for task: Task) {
        titleLabel.text = task.title
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - LIFE CYCLE

}

extension UINib {
    static let classNib = "UIDraggableSession"
}
