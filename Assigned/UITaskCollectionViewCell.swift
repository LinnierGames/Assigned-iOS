//
//  TaskCollectionViewCell.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/3/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class UITaskCollectionViewCell: UICollectionViewCell {
    
    enum Types {
        struct Info {
            var cellIdentifier: String
            var nib: UINib
            
            init(id: String, nibTitle: String) {
                cellIdentifier = id
                nib = UINib(nibName: nibTitle, bundle: Bundle.main)
            }
        }
        
        static var baseCell = Info(id: "task - draggable", nibTitle: "UITaskCollectionViewCell")
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func configure(_ assignment: Assignment) {
        self.imagePriority.priority = assignment.priority
        self.labelTitle.text = assignment.title
        if let deadline = assignment.deadline {
            self.labelSubtitle.text = String(timeInterval: Date().timeIntervalSince(deadline))
        } else {
            self.labelSubtitle.text = nil
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var imagePriority: UIPriorityBox!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    
    // MARK: - LIFE CYCLE

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
