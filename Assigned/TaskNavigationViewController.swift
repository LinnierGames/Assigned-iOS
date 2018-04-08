//
//  TaskNavigationViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/20/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class TaskNavigationViewController: UIViewController {
    
    static let TOP_MARGIN: CGFloat = 48.0
    static let BOTTOM_MARGIN: CGFloat = 58.0
    
    private(set) var viewModel = TaskNavigationViewModel()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var task: Task {
        set {
            self.viewModel.task = newValue
        }
        get {
            return self.viewModel.task
        }
    }
    
    var taskParentDirectory: Directory? {
        set {
            
            // fetch the same parent in the different context
            if let parent = newValue {
                let newParent = viewModel.context.object(with: parent.objectID) as! Directory
                task.parentDirectory = newParent
            } else {
                task.parentDirectory = nil
            }
        }
        get {
            return task.parentDirectory
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
                
            case UIStoryboardSegue.embedTaskVc:
                guard let vc = segue.destination as? TaskViewController else {
                    fatalError("TaskViewController not set up in storyboard")
                }
                
                vc.parentNavigationViewController = self
            case UIStoryboardSegue.embedSessionVc:
                guard let vc = segue.destination as? SessionViewController else {
                    fatalError("SessionViewController not set up in storyboard")
                }
                
                vc.parentNavigationViewController = self
            case UIStoryboardSegue.embedNotesVc:
                guard let vc = segue.destination as? NotesViewController else {
                    fatalError("NotesViewController not set up in storyboard")
                }
                
                vc.parentModel = self.viewModel
            default: break
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let model = object as? TaskNavigationViewModel, model === viewModel, keyPath! == "editingMode" {
            updateUI()
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var viewTask: UIView!
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

// MARK: - UIScrollViewDelegate

extension TaskNavigationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: - UIStoryboardSegue

private extension UIStoryboardSegue {
    static let embedTaskVc = "embed task vc"
    static let embedSessionVc = "embed sessions vc"
    static let embedNotesVc = "embed notes vc"
}
