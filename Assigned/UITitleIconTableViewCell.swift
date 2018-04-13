//
//  UITitleIconTableViewCell.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/12/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class UITitleIconTableViewCell: UITableViewCell {
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    static let reusableIdentifier = "title icon cell"

    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    // MARK: - LIFE CYCLE
    
}
