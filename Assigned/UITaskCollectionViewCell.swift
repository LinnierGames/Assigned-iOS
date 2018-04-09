//
//  TaskCollectionViewCell.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/3/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

@objc protocol UITaskCollectionViewCellDelegate: class {
    @objc optional func taskCollection(cell: UITaskCollectionViewCell, didBegin gesture: UILongPressGestureRecognizer)
    @objc optional func taskCollection(cell: UITaskCollectionViewCell, didChange gesture: UILongPressGestureRecognizer)
    @objc optional func taskCollection(cell: UITaskCollectionViewCell, didEnd gesture: UILongPressGestureRecognizer)
    @objc optional func taskCollection(cell: UITaskCollectionViewCell, didLongTap gesture: UILongPressGestureRecognizer, with state: UIGestureRecognizerState)
}

class UITaskCollectionViewCell: UICollectionViewCell {
    
    enum Types {
        struct Info {
            var cellIdentifier: String
            var nib: UINib
            
            init(id: String, nibTitle: String) {
                cellIdentifier = id
                nib = UINib(nibName: nibTitle, bundle: Bundle.main)
            }
        }
        
        static var baseCell = Info(id: "task - draggable", nibTitle: "UITaskCollectionViewCell")
    }
    
    weak var delegate: UITaskCollectionViewCellDelegate?
    
    private(set) lazy var longTapGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(UITaskCollectionViewCell.didLongTap(gesture:)))
        self.contentView.addGestureRecognizer(gesture)
        
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
        self.imagePriority.priority = task.priority
        self.labelTitle.text = task.title
        if let deadline = task.deadline {
            self.labelSubtitle.text = String(timeInterval: Date().timeIntervalSince(deadline))
        } else {
            self.labelSubtitle.text = nil
        }
    }
    
    @objc private func didLongTap(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            delegate?.taskCollection?(cell: self, didBegin: gesture)
            delegate?.taskCollection?(cell: self, didLongTap: gesture, with: gesture.state)
        case .changed:
            delegate?.taskCollection?(cell: self, didChange: gesture)
            delegate?.taskCollection?(cell: self, didLongTap: gesture, with: gesture.state)
        case .ended:
            delegate?.taskCollection?(cell: self, didEnd: gesture)
            delegate?.taskCollection?(cell: self, didLongTap: gesture, with: gesture.state)
        default:
            delegate?.taskCollection?(cell: self, didLongTap: gesture, with: gesture.state)
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var imagePriority: UIPriorityBox!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    
    // MARK: - LIFE CYCLE

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
