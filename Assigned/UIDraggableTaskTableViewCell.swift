//
//  TaskCollectionViewCell.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/3/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

@objc protocol UIDraggableTaskTableViewCellGestureDelegate: class, UIGestureRecognizerDelegate {
    
    // gesture delegate
    @objc optional func task(cell: UIDraggableTaskTableViewCell, didBeginDragging gesture: UILongPressGestureRecognizer, toCreateA_SessionFor task: Task?)
    @objc optional func task(cell: UIDraggableTaskTableViewCell, didChangeDragging gesture: UILongPressGestureRecognizer, toCreateA_SessionFor task: Task?)
    @objc optional func task(cell: UIDraggableTaskTableViewCell, didEndDragging gesture: UILongPressGestureRecognizer, toCreateA_SessionFor task: Task?)
    @objc optional func task(cell: UIDraggableTaskTableViewCell, didLongTap gesture: UILongPressGestureRecognizer, with state: UIGestureRecognizerState, toCreateA_SessionFor task: Task?)
}

@objc protocol UIDraggableTaskTableViewCellDelegate: class {
    
    // cell delegate
    @objc optional func task(cell: UIDraggableTaskTableViewCell, didPress checkbox: UIButton, with newState: Bool)
    
}

class UIDraggableTaskTableViewCell: UITableViewCell {
    
    private var viewModel = UIDraggableTaskTableViewModel()
    
    enum Types {
        struct Info {
            var cellIdentifier: String
            var nib: UINib
            
            init(id: String, nibTitle: String) {
                cellIdentifier = id
                nib = UINib(nibName: nibTitle, bundle: Bundle.main)
            }
        }
        
        static var baseCell = Info(id: "task - draggable", nibTitle: "UIDraggableTaskTableViewCell")
    }
    
    enum State {
        case normal
        case dragging
    }
    
    var cellState: State = .normal {
        didSet {
            self.updateUI()
        }
    }
    
    weak var gestureDelegate: UIDraggableTaskTableViewCellGestureDelegate?
    
    weak var delegate: UIDraggableTaskTableViewCellDelegate?
    
    weak var task: Task?
    
    private(set) lazy var longTapGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(UIDraggableTaskTableViewCell.didLongTap(gesture:)))
        gesture.minimumPressDuration = 0.02
        self.viewDragHitBox?.addGestureRecognizer(gesture)
        
        return gesture
    }()
    
    /** Activate the gesture by setting its delegate to a new value */
    var longTapGestureDelegate: UIGestureRecognizerDelegate? {
        set {
            longTapGesture.delegate = newValue
        }
        get {
            return longTapGesture.delegate
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func configure(_ task: Task) {
        self.viewModel.task = task
        
        self.buttonCheckbox.isChecked = task.isCompleted
        
//        self.imagePriority.priority = task.priority
        self.labelTitle.text = task.title
        if let _ = task.deadline {
            self.labelDeadline.attributedText = self.viewModel.deadlineText
        } else {
            self.labelDeadline.text = "no deadline"
        }
        if let subtasks = task.subtasks, subtasks.count != 0 {
            let nCompletedSubtasks = subtasks.numberOfCompletedSubtasks
            self.labelSubtasks.text = "\(nCompletedSubtasks) of \(subtasks.count)"
        } else {
            self.labelSubtasks.text = nil
        }
        
        self.task = task
        
        self.updateUI()
    }
    
    @objc private func didLongTap(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            gestureDelegate?.task?(cell: self, didBeginDragging: gesture, toCreateA_SessionFor: self.task)
            gestureDelegate?.task?(cell: self, didLongTap: gesture, with: gesture.state, toCreateA_SessionFor: self.task)
            self.cellState = .dragging
        case .changed:
            gestureDelegate?.task?(cell: self, didChangeDragging: gesture, toCreateA_SessionFor: self.task)
            gestureDelegate?.task?(cell: self, didLongTap: gesture, with: gesture.state, toCreateA_SessionFor: self.task)
            self.cellState = .dragging
        case .ended:
            gestureDelegate?.task?(cell: self, didEndDragging: gesture, toCreateA_SessionFor: self.task)
            gestureDelegate?.task?(cell: self, didLongTap: gesture, with: gesture.state, toCreateA_SessionFor: self.task)
            self.cellState = .normal
        default:
            gestureDelegate?.task?(cell: self, didLongTap: gesture, with: gesture.state, toCreateA_SessionFor: self.task)
        }
    }
    
    private func updateUI() {
//        switch self.cellState {
//        case .normal:
//            self.backgroundColor = UIColor.lightGray
//            self.labelTitle.textColor = .black
//            self.alpha = 1.0
//        case .dragging:
//            self.backgroundColor = UIColor.black
//            self.labelTitle.textColor = .white
//            self.alpha = 0.35
//        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(animated, animated: animated)
        
        //TODO: hide drag image view when editing
//        if editing {
//            viewDragHitBox.isUserInteractionEnabled = false
//            imageDrag.alpha = 0.0
//        } else {
//            viewDragHitBox.isUserInteractionEnabled = true
//            imageDrag.alpha = 1.0
//        }
    }
    
    // MARK: - IBACTIONS
    
//    @IBOutlet weak var imagePriority: UIPriorityBox!
    @IBOutlet weak var viewDragHitBox: UIView!
    @IBOutlet weak var imageDrag: UIImageView!
    @IBOutlet weak var checkbox: UICheckbox!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtasks: UILabel!
    @IBOutlet weak var labelDeadline: UILabel!
    
    @IBOutlet weak var buttonCheckbox: UICheckbox!
    @IBAction func pressCheckbox(_ sender: Any) {
        self.buttonCheckbox.isChecked.invert()
        
        self.delegate?.task?(cell: self, didPress: buttonCheckbox, with: self.buttonCheckbox.isChecked)
    }
    
    // MARK: - LIFE CYCLE

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
