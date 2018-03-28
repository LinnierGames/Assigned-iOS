//
//  AssignmentNavigationViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/20/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class AssignmentNavigationViewController: UIViewController {
    
    private(set) var viewModel = AssignmentNavigationViewModel()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var assignment: Assignment {
        set {
            self.viewModel.assignment = newValue
        }
        get {
            return self.viewModel.assignment
        }
    }
    
    var assignmentParentDirectory: Directory? {
        set {
            
            // fetch the same parent in the different context
            if let parent = newValue {
                let newParent = viewModel.context.object(with: parent.objectID) as! Directory
                assignment.parentDirectory = newParent
            } else {
                assignment.parentDirectory = nil
            }
        }
        get {
            return assignment.parentDirectory
        }
    }
    
    var editingMode: CRUD {
        set {
            self.viewModel.editingMode = newValue
        }
        get {
            return self.viewModel.editingMode
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "embedded assignment vc":
                guard let vc = segue.destination as? AssignmentViewController else {
                    fatalError("AssignmentViewController not set up in storyboard")
                }
                
                vc.parentNavigationViewController = self
            case "embedded sessions vc":
                guard let vc = segue.destination as? AssignmentSessionViewController else {
                    fatalError("AssignmentSessionViewController not set up in storyboard")
                }
                
                vc.parentNavigationViewController = self
            case "embedded notes vc":
                guard let _ = segue.destination as? AssignmentNotesViewController else {
                    fatalError("AssignmentNotesViewController not set up in storyboard")
                }
                
            default: break
            }
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var constraintScrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let screenWidth = self.view.bounds.width
//        let pageWidth = screenWidth - 24.0
//        let mutiplier = pageWidth / screenWidth * 3
//
//        NSLayoutConstraint(item: stackView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.width, multiplier: mutiplier, constant: 0).isActive = true
//        self.view.layoutIfNeeded()
    }
}

extension AssignmentNavigationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
