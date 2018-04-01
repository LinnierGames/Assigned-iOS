//
//  AssignmentNotesViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/20/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class AssignmentNotesViewController: UIViewController {
    
    weak var parentModel: AssignmentNavigationViewModel!
    
    private var assignment: Assignment {
        get {
            return parentModel.assignment
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var labelAssignmentTitle: UILabel!
    @IBOutlet weak var textviewNotes: UITextView!
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let inputView = UIInputAccessoryView.initialize(accessoryType: .Dismiss)
        inputView.addActionToRightButton(action: { [unowned self] (_) in
            self.textviewNotes.resignFirstResponder()
        })
        textviewNotes.inputAccessoryView = inputView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: RxSwift
        self.textviewNotes.text = assignment.notes
        self.labelAssignmentTitle.text = assignment.title
    }
}

extension AssignmentNotesViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        
        //TODO: RxSwift
        assignment.notes = textView.text
        parentModel.saveOnlyOnReading()
    }
}
