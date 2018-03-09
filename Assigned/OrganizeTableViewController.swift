//
//  OrganizeTableViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class OrganizeTableViewController: UITableViewController {
    
    // MARK: - RETURN VALUES
    
    // MARK: Table View Data Source
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    @IBAction func pressAdd(_ sender: Any) {
        
    }
    
    @IBAction func pressProfile(_ sender: Any) { }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib.assignmentCells(), forCellReuseIdentifier: UIAssignmentTableViewCell.Types.baseCell)
    }

}
