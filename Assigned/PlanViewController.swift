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
    
    private weak var dayViewController: CalendarDayViewController!
    
    private lazy var viewModel = PlanViewModel()
    
    var selectedDate: Date {
        set {
            
            // updates the task fetched results controller
            self.taskPanelViewController.selectedDay = newValue
            
            // updates the dayView
            self.dayViewController.selectedDate = newValue
        }
        get {
            return self.dayViewController.selectedDate
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    enum ViewState {
        case Hidden
        case Minimized
        case Expanded
        
        /**
         decrement to a smaller state
         */
        mutating func colaspe() {
            switch self {
            case .Expanded:
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
            case .Expanded:
                break
            case .Minimized:
                self = .Expanded
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
            self.setTaskPanel(to: self.taskPanelViewState)
            
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
    private let BOTTOM_MINIZIED_VERTICAL_MARGIN: CGFloat = 192.0
    private let BOTTOM_HIDDEN_VERTICAL_MARGIN: CGFloat = 64
    func setTaskPanel(to newState: ViewState, animated: Bool = true) {
        guard let windowSize = self.view?.frame.size else {
            return print("setTaskPanel was invoked before the view was initialized")
        }
        
        switch newState {
        case .Hidden:
            self.constraintTopSpacing.constant = windowSize.height - self.BOTTOM_HIDDEN_VERTICAL_MARGIN
            self.taskPanelViewController.setDisplayToHidden()
            self.viewForeground.enableTouchBarrier = false
        case .Minimized:
            self.constraintTopSpacing.constant = windowSize.height - self.BOTTOM_MINIZIED_VERTICAL_MARGIN
            self.taskPanelViewController.setDisplayToMinizied()
            self.viewForeground.enableTouchBarrier = false
        case .Expanded:
            self.constraintTopSpacing.constant = self.TOP_VERTICAL_MARGIN
            self.taskPanelViewController.setDisplayToExpanded()
            self.viewForeground.enableTouchBarrier = true
        }
        self.taskPanelViewState = newState
        
        if animated {
            UIView.animate(withDuration: TimeInterval.transitionAnimationDuration, delay: 0.0, options: .curveEaseOut, animations: { [unowned self] in
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
            case UIStoryboardSegue.embedTaskPanel:
                guard let vc = segue.destination as? TaskPanelViewController else {
                    fatalError("TaskPanelViewController was not set correctly in the storyboard")
                }
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PlanViewController.didPanTaskPanel(_:)))
                vc.panGesture = panGesture
                self.taskPanelViewController = vc
            case UIStoryboardSegue.embedDayPanel:
                guard let vc = segue.destination as? CalendarDayViewController else {
                    fatalError("PlannerDayViewController was not set correctly in the storyboard")
                }
                
                vc.calendarDelegate = self
                self.dayViewController = vc
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
            self.constraintTopSpacing.constant = size.height - self.BOTTOM_MINIZIED_VERTICAL_MARGIN
        case .Expanded:
            self.constraintTopSpacing.constant = self.TOP_VERTICAL_MARGIN
        }
        
        // Adjust the height of the task panel
        self.constraintHeight.constant = size.height
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var viewForeground: UITouchBarrier!
    
    @IBAction func pressToday(_ sender: Any) {
        self.selectedDate = Date()
    }
    
    @IBOutlet weak var viewTaskPanel: UIView!
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.hideBottomShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTaskPanel(to: self.taskPanelViewState, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PrivacyService.Calendar.authorize(
            successfulHandler: nil,
            failureHandler: { [unowned self] in
                PrivacyService.Calendar.promptAlert(in: self, with: .alert)
        })
    }
}

// MARK: - CalendarDayViewControllerDelegate

extension PlanViewController: CalendarDayViewControllerDelegate {
    func planner(controller: CalendarDayViewController, didChangeTo date: Date) {
        
        // updates the selected date in the task panel, and reloads its data
        self.taskPanelViewController.selectedDay = date
    }
    
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        //TODO: switch on param: action (.done, .responded, .deleted)
        self.dismiss(animated: true)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        //TODO: switch on param: action (.canceled, .saved, .deleted)
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

// MARK: - UITaskCollectionViewCellDelegate

extension PlanViewController: UITaskCollectionViewCellDelegate, UIGestureRecognizerDelegate {
    static var currentDraggingView: UIDraggableSessionCell?
    static var touchOffset: CGPoint?
    
    func taskCollection(cell: UITaskCollectionViewCell, didBeginDragging gesture: UILongPressGestureRecognizer, toCreateA_SessionFor task: Task?) {
        guard let task = task else {
            return
        }
        
        let cellSize = CGSize(width: cell.frame.size.width, height: 45.0)
        let cellOrigin = self.view.convert(cell.frame.origin, from: cell.superview)
        let newSessionView = UIDraggableSessionCell(task: task, withCopied: CGRect(origin: cellOrigin, size: cellSize))
        
        newSessionView.backgroundColor = viewModel.defaultCalendarColor
        PlanViewController.currentDraggingView = newSessionView
        PlanViewController.touchOffset = cell.frame.origin - gesture.location(in: cell.superview)
        self.view.addSubview(newSessionView)
        
        // also, adjust the width to match the calendar day view
        let draggableViewWidth = self.dayViewController.eventWidth
        newSessionView.frame.size.width = draggableViewWidth
        
        self.setTaskPanel(to: .Hidden)
    }
    
    func taskCollection(cell: UITaskCollectionViewCell, didChangeDragging gesture: UILongPressGestureRecognizer, toCreateA_SessionFor task: Task?) {
        guard
            let draggingView = PlanViewController.currentDraggingView,
            let touchOffset = PlanViewController.touchOffset else {
                return assertionFailure("longpress gesture did change without the inital draggingView/touch offset")
        }
        
        //TODO: animate position and resizing
        // update location and snap to the right edge of the screen
        let todaysTimelineContainer = self.dayViewController.timelineContainer
        
        // get point
        // convert into todays time line cartiesian plane
        var location = gesture.location(in: todaysTimelineContainer)
        
        // round
        let intervalSize:CGFloat = 45.0*0.25
        let roundedInt = Int((location.y + touchOffset.y) / (intervalSize))
        location.y = CGFloat(roundedInt) * intervalSize + 10.0 // every 15 mins
        
        // prevent new location.y to go beyond the scroll view's content size
        location.y = max(0, location.y)
        
        // convert back into self.view cartiesian plane
        location = self.view.convert(location, from: todaysTimelineContainer)
        
        // prevent location.y to go beyond the scroll view's top bounds
        let dayHeaderViewFrame = self.view.convert(self.dayViewController.dayHeaderView.frame, from: self.dayViewController.view)
        let bottomDayHeaderPoint = dayHeaderViewFrame.origin.y + dayHeaderViewFrame.size.height
        location.y = max(bottomDayHeaderPoint, location.y)

        // left inset
        let screenWidth = self.view.frame.size.width
        let leftAlign = screenWidth - draggingView.frame.size.width
        
        // udpate the position
        draggingView.frame.origin = CGPoint(x: leftAlign, y: location.y)
    }
    
    func taskCollection(cell: UITaskCollectionViewCell, didEndDragging gesture: UILongPressGestureRecognizer, toCreateA_SessionFor task: Task?) {
        let todaysTimeline = self.dayViewController.timelineContainer
        guard
            let draggingView = PlanViewController.currentDraggingView,
            var dragLocationOrigin = PlanViewController.currentDraggingView?.frame.origin else {
                return assertionFailure("longpress gesture did end without the inital draggingView offset")
        }
        
        guard let task = task else {
            fatalError("no task was given")
        }
        
        dragLocationOrigin = todaysTimeline.timeline.convert(dragLocationOrigin, from: self.view)
        
        let newDate = todaysTimeline.date(for: dragLocationOrigin, with: self.selectedDate)
        
        viewModel.addSession(for: task, at: newDate)
                
        draggingView.removeFromSuperview()
        PlanViewController.currentDraggingView = nil
        PlanViewController.touchOffset = nil
        
        self.setTaskPanel(to: .Minimized)
    }
}

// MARK: - UINavigationBarDelegate

extension PlanViewController: UINavigationBarDelegate {
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - UIStoryboardSegue

private extension UIStoryboardSegue {
    static let embedTaskPanel = "embed task panel"
    static let embedDayPanel = "embed day planner"
}

