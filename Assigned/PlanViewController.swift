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
    
    enum ViewState {
        case Hidden //TODO: implement hidden task panel
        case Minimized
        case Shown
    }
    
    var isShowingTaskPanel: ViewState = .Minimized
    
    private var touchOffset: CGFloat?
    private var originPoint: CGPoint?
    
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
            
            if location.y > originPoint.y {
                self.setView(to: .Minimized)
            } else {
                self.setView(to: .Shown)
            }
            
            self.originPoint = nil
            self.touchOffset = nil
        default:
            break
        }
    }
    
    /** top spacing between the task panel and the safe area */
    @IBOutlet weak var constraintTopSpacing: NSLayoutConstraint!
    
    /** height of the task panel view */
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    
    private let TOP_VERTICAL_MARGIN: CGFloat = 48.0
    private let BOTTOM_VERTICAL_MARGIN: CGFloat = 128.0
    private func setView(to newState: ViewState, animated: Bool = true) {
        guard let windowSize = self.view?.frame.size else {
            return print("self.view was not set")
        }
        
        switch newState {
        case .Hidden:
            break
        case .Minimized:
            self.constraintTopSpacing.constant = windowSize.height - self.BOTTOM_VERTICAL_MARGIN
        case .Shown:
            self.constraintTopSpacing.constant = self.TOP_VERTICAL_MARGIN
        }
        self.isShowingTaskPanel = newState
        
        if animated {
            UIView.animate(withDuration: TimeInterval.transitionImmediatelyAnimationDuration, delay: 0.0, options: .curveEaseOut, animations: { [unowned self] in
                self.view.layoutIfNeeded()
            })
        } else {
            self.view.setNeedsLayout()
        }
        
        // Adjust the height of the task panel
        self.constraintHeight.constant = windowSize.height
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
        
        // Adjust the y posistion
        switch self.isShowingTaskPanel {
        case .Hidden:
            break
        case .Minimized:
            self.constraintTopSpacing.constant = size.height - self.BOTTOM_VERTICAL_MARGIN
        case .Shown:
            self.constraintTopSpacing.constant = self.TOP_VERTICAL_MARGIN
        }
        
        // Adjust the height of the task panel
        self.constraintHeight.constant = size.height
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonFinish: UIButton!
    @IBAction func pressFinish(_ sender: Any) {
        self.presentingViewController!.dismiss(animated: true)
    }
    
    @IBOutlet weak var viewTaskPanel: UIView!
    @IBAction func addCalendar(_ sender: Any) {
    
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setView(to: self.isShowingTaskPanel, animated: false)
    }
}
