//
//  NotesViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/20/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    weak var parentModel: TaskNavigationViewModel!
    
    private var task: Task {
        get {
            return parentModel.task
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var contraintCardHeight: NSLayoutConstraint!
    @IBOutlet weak var labelTaskTitle: UILabel!
    @IBOutlet weak var textviewNotes: UITextView!
    
    //TODO: adjust text view when keyboard appears
    @IBOutlet weak var constraintBottomTextView: NSLayoutConstraint!
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contraintCardHeight.constant = self.view.frame.size.height - (TaskNavigationViewController.TOP_MARGIN + TaskNavigationViewController.BOTTOM_MARGIN)
        self.view.layoutIfNeeded()
        
        let inputView = UIInputAccessoryView.initialize(accessoryType: .Dismiss)
        inputView.addActionToRightButton(action: { [unowned self] (_) in
            self.textviewNotes.resignFirstResponder()
        })
        textviewNotes.inputAccessoryView = inputView
        
//        self.view.bluryCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: RxSwift
        self.textviewNotes.text = task.notes
        self.labelTaskTitle.text = task.title
    }
}

extension NotesViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        
        //TODO: RxSwift
        task.notes = textView.text
        parentModel.saveOnlyOnReading()
    }
}
