//
//  PlanViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/3/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class PlanViewController: UIViewController {
    
    private weak var taskPanelViewController: TaskPanelViewController!
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private enum ViewState {
        case Hidden
        case Shown
    }
    
    var isShowingTaskPanel: Bool = false {
        didSet {
            if isShowingTaskPanel {
                self.setView(to: .Shown)
            } else {
                self.setView(to: .Hidden)
            }
        }
    }
    
    private var touchOffset: CGFloat?
    private var originPoint: CGPoint?
    
    /** top spacing between the task panel and the safe area */
    @IBOutlet weak var constraintTopSpacing: NSLayoutConstraint!
    @objc private func didPanTaskPanel(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let location = gesture.location(in: self.view)
            touchOffset = location.y - viewTaskPanel.frame.origin.y
            originPoint = location
        case .changed:
            guard let touchOffset = self.touchOffset else {
                return assertionFailure("No touch offset was made in the .began state of this gesture")
            }
            
            let newPoint = gesture.location(in: self.view)
            viewTaskPanel.frame.origin.y = newPoint.y - touchOffset
        case .ended:
            guard let originPoint = self.originPoint else {
                return assertionFailure("No origin point was made in the .began state of this gesture")
            }
            
            let location = gesture.location(in: self.view)
            
            // hide the task panel
            if location.y > originPoint.y {
                self.isShowingTaskPanel = false
                
                // show the task panel
            } else {
                self.isShowingTaskPanel = true
            }
            
            self.originPoint = nil
            self.touchOffset = nil
        default:
            break
        }
    }
    
    private let TOP_VERTICAL_SPACING: CGFloat = 48.0
    private let BOTTOM_VERTICAL_MARGIN: CGFloat = 128.0
    private func setView(to newState: ViewState) {
        guard let windowSize = self.view.window?.frame.size else {
            return print("no window was set")
        }
        
        switch newState {
        case .Hidden:
            UIView.animate(withDuration: TimeInterval.transitionAnimationDuration, animations: { [unowned self] in
                self.constraintTopSpacing.constant = windowSize.height - self.BOTTOM_VERTICAL_MARGIN
                self.viewTaskPanel.layoutIfNeeded()
                
//                self.viewTaskPanel.frame.origin.y = windowSize.height - self.BOTTOM_VERTICAL_MARGIN
            })
        case .Shown:
            UIView.animate(withDuration: TimeInterval.transitionAnimationDuration, animations: { [unowned self] in
                self.constraintTopSpacing.constant = self.TOP_VERTICAL_SPACING
                self.viewTaskPanel.layoutIfNeeded()
//                self.viewTaskPanel.frame.origin.y = self.TOP_VERTICAL_SPACING
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "embed task panel":
                guard let vc = segue.destination as? TaskPanelViewController else {
                    fatalError("TaskPanelViewController was not set correctly in the storyboard")
                }
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PlanViewController.didPanTaskPanel(_:)))
                vc.panGesture = panGesture
                self.taskPanelViewController = vc
            default: break
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let windowSize = size
        if self.isShowingTaskPanel {
            self.constraintTopSpacing.constant = self.TOP_VERTICAL_SPACING
        } else {
            self.constraintTopSpacing.constant = windowSize.height - self.BOTTOM_VERTICAL_MARGIN
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonFinish: UIButton!
    @IBAction func pressFinish(_ sender: Any) {
        self.presentingViewController!.dismiss(animated: true)
    }
    
    @IBOutlet weak var viewTaskPanel: UIView!
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let windowSize = self.view?.frame.size else {
            return print("no window was set")
        }
        
        if self.isShowingTaskPanel {
            self.constraintTopSpacing.constant = self.TOP_VERTICAL_SPACING
        } else {
            self.constraintTopSpacing.constant = windowSize.height - self.BOTTOM_VERTICAL_MARGIN
        }
        self.viewTaskPanel.layoutIfNeeded()
    }
}
