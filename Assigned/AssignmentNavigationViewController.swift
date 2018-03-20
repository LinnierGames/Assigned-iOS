//
//  AssignmentNavigationViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/20/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class AssignmentNavigationViewController: UIViewController {
    
    var assignment: Assignment!
    
    var assignmentParentDirectory: Directory?
    
    var editingMode: CRUD = .Create
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var assignmentVc: AssignmentViewController!
    
    private var sessionVc: AssignmentSessionViewController!
    
    private var notesVc: AssignmentNotesViewController!
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "embedded assignment vc":
                guard let vc = segue.destination as? AssignmentViewController else {
                    fatalError("AssignmentViewController not set up in storyboard")
                }
                
                assignmentVc = vc
                assignmentVc.assignment = self.assignment
                assignmentVc.assignmentParentDirectory = self.assignmentParentDirectory
                assignmentVc.editingMode = self.editingMode
            case "embedded sessions vc":
                guard let vc = segue.destination as? AssignmentSessionViewController else {
                    fatalError("AssignmentSessionViewController not set up in storyboard")
                }
                
                sessionVc = vc
            case "embedded notes vc":
                guard let vc = segue.destination as? AssignmentNotesViewController else {
                    fatalError("AssignmentNotesViewController not set up in storyboard")
                }
                
                notesVc = vc
            default: break
            }
        }
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = self.view.frame.size
        scrollView.contentSize.width = screenSize.width * 3
        scrollView.contentSize.height = screenSize.height
        scrollView.layoutIfNeeded()
    }
}
