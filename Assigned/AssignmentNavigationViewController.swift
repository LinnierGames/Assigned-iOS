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
    
    deinit {
        viewModel.removeObserver(self, forKeyPath: "editingMode")
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI(animated: Bool = true) {
        
        let showCards = { [unowned self] in
            self.scrollView?.isScrollEnabled = true
            self.scrollView?.alwaysBounceHorizontal = true
            
            self.viewSessions?.alpha = 1.0
            self.viewNotes?.alpha = 1.0
        }
        
        let hideCards = { [unowned self] in
            self.scrollView?.isScrollEnabled = false
            self.scrollView?.alwaysBounceHorizontal = false
            
            self.viewSessions?.alpha = 0.0
            self.viewNotes?.alpha = 0.0
        }
        
        if animated {
            UIView.animate(withDuration: TimeInterval.transitionAnimationDuration) {
                if self.editingMode.isReading {
                    showCards()
                } else {
                    hideCards()
                }
            }
        } else {
            if self.editingMode.isReading {
                showCards()
            } else {
                hideCards()
            }
        }
    }
    
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
                guard let vc = segue.destination as? AssignmentNotesViewController else {
                    fatalError("AssignmentNotesViewController not set up in storyboard")
                }
                
                vc.parentModel = self.viewModel
            default: break
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let model = object as? AssignmentNavigationViewModel, model === viewModel, keyPath! == "editingMode" {
            updateUI()
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var viewAssignment: UIView!
    @IBOutlet weak var viewSessions: UIView!
    @IBOutlet weak var viewNotes: UIView!
    
    @IBOutlet weak var constraintScrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.addObserver(self, forKeyPath: "editingMode", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI(animated: false)
    }
}

extension AssignmentNavigationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
