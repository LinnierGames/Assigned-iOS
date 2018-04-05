//
//  PlanViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/3/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import EventKitUI

class PlanViewController: UIViewController, UINavigationControllerDelegate {
    
    private weak var taskPanelViewController: TaskPanelViewController!
    
    private lazy var calendar: CalendarStack = {
        do {
            return try CalendarStack()
        } catch let err {
            fatalError(err.localizedDescription)
        }
    }()
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    enum ViewState {
        case Hidden //TODO: implement hidden task panel
        case Minimized
        case Shown
        
        /**
         decrement to a smaller state
         */
        mutating func colaspe() {
            switch self {
            case .Shown:
                self = .Minimized
            case .Minimized:
                self = .Hidden
            case .Hidden:
                break
            }
        }
        
        /**
         increment to a smaller state
         */
        mutating func expand() {
            switch self {
            case .Shown:
                break
            case .Minimized:
                self = .Shown
            case .Hidden:
                self = .Minimized
            }
        }
    }
    
    //TODO: OFL - animate from hidden to minized and back to hidden
    var taskPanelViewState: ViewState = .Minimized
    
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
                self.taskPanelViewState.colaspe()
            } else {
                self.taskPanelViewState.expand()
            }
            self.setView(to: self.taskPanelViewState)
            
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
    private let BOTTOM_HIDDEN_VERTICAL_MARGIN: CGFloat = 32.0
    private func setView(to newState: ViewState, animated: Bool = true) {
        guard let windowSize = self.view?.frame.size else {
            return print("self.view was not set")
        }
        
        switch newState {
        case .Hidden:
            self.constraintTopSpacing.constant = windowSize.height - self.BOTTOM_HIDDEN_VERTICAL_MARGIN
        case .Minimized:
            self.constraintTopSpacing.constant = windowSize.height - self.BOTTOM_VERTICAL_MARGIN
        case .Shown:
            self.constraintTopSpacing.constant = self.TOP_VERTICAL_MARGIN
        }
        self.taskPanelViewState = newState
        
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
            case "embed day planner":
                guard let vc = segue.destination as? PlannerDayViewController else {
                    fatalError("PlannerDayViewController was not set correctly in the storyboard")
                }
                
                vc.calendarDelegate = self
            default: break
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Adjust the y posistion
        switch self.taskPanelViewState {
        case .Hidden:
            self.constraintTopSpacing.constant = size.height - self.BOTTOM_HIDDEN_VERTICAL_MARGIN
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
    @IBOutlet weak var buttonAddEvent: UIBarButtonItem!
    @IBAction func addEventCalendar(_ sender: Any) {
        calendar.presentNewEvent(for: self)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setView(to: self.taskPanelViewState, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PrivacyService.Calendar.authorize(
            successfulHandler: { [unowned self] in
                self.buttonAddEvent.isEnabled = true
            },
            failureHandler: { [unowned self] in
                self.buttonAddEvent.isEnabled = false
                UIAlertController(title: "Access to iCal", message: "Assigned needs to have access to your calendar. Please open the Settings app and enable Calendar", preferredStyle: .alert)
                    .addConfirmationButton(title: "Open Settings", with: { (action) in
                        
                        // url to open settings
                        UIApplication.shared.openAppSettings()
                    })
                    .present(in: self)
        })
    }
}

extension PlanViewController: EKEventViewDelegate {
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        //TODO: switch on action (.done, .responded, .deleted)
        self.dismiss(animated: true)
    }
}

extension PlanViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        //TODO: switch on action (.canceled, .saved, .deleted)
        controller.dismiss(animated: true)
    }
    
    //    func eventEditViewControllerDefaultCalendar(forNewEvents controller: EKEventEditViewController) -> EKCalendar {
    //
    //        guard let calendar = self.calendar.eventStore.defaultCalendarForNewEvents else {
    //            fatalError("no default calendar")
    //        }
    //
    //        return calendar
    //    }
}

