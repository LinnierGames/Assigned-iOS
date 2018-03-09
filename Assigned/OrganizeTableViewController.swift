//
//  OrganizeTableViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/9/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CoreData

class OrganizeTableViewController: FetchedResultsTableViewController {
    
    var viewModel = OrganizeViewModel()
    
    // MARK: - RETURN VALUES
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UIAssignmentTableViewCell.Types.baseCell) as! UIAssignmentTableViewCell?
            else {
                assertionFailure("custom cell did not load")
                
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        let directory = fetchedResultsController.directory(at: indexPath)
        let assignment = directory.assignment
        cell.configure(assignment)
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        self.updateFetch()
    }
    
    private func updateFetch() {
        let fetch: NSFetchRequest<Directory> = Directory.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(key: "info.title",
                             ascending: false,
                             selector: #selector(NSString.localizedStandardCompare(_:))
            )
        ]
        self.fetchedResultsController = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: fetch as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: viewModel.managedObjectContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
    }
    
    // MARK: - IBACTIONS
    
    @IBAction func pressAdd(_ sender: Any) {
        let alertAddAssignment = UIAlertController(title: "Add an Assignment", message: "enter a title", preferredStyle: .alert)
        
        alertAddAssignment
            .addTextField(placeholderText: "e.g. Create Project Outline")
            .addCancelButton()
            .addButton(title: "Add") { (action) in
                if let newTitle = alertAddAssignment.inputField.text {
                    self.viewModel.addAssignment(with: newTitle)
                }
            }
            .present(in: self)
    }
    
    @IBAction func pressProfile(_ sender: Any) { }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib.assignmentCells(), forCellReuseIdentifier: UIAssignmentTableViewCell.Types.baseCell)
        
        //TODO: Dynamic Font
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        saveHandler = viewModel.save
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
    }

}
