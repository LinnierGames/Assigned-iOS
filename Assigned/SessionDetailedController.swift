//
//  SessionViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/20/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

protocol SessionDetailedControllerDelegate: class {
    func session(controller: SessionDetailedController, didFinishEditing session: Session)
    func session(controller: SessionDetailedController, didDelete session: Session)
}

class SessionDetailedController: UIViewController {
    
    var viewModel = SessionDetailedViewModel()
    
    weak var delegate: SessionDetailedControllerDelegate?
    
    public var session: Session {
        set {
            viewModel.session = newValue
        }
        get {
            return viewModel.session
        }
    }

    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        
        // Title
        let sessionTask = session.task
        
        textfieldTitle.text = session.title
        labelTaskTitle.text = sessionTask.title
        
        sessionStartDate = session.startDate
        sessionDuration = session.duration
        
        // Start Date
        labelStartDate.text = viewModel.textStartDate
        
        //TODO: RxSwift
        labelEndDate.text = viewModel.textEndDate
        labelDuration.text = viewModel.textDuration
        
        // Duration
//        let anHour = CTDateComponentHour
        //TODO: implement duration slider class
    }
    
    private func dismissViewController() {
        guard let presentingVc = self.presentingViewController else {
            fatalError("no parent vc presented this vc")
        }
        
        presentingVc.dismiss(animated: true)
    }
    
    // MARK: - IBACTIONS
    
    @IBAction func pressDone(_ sender: Any) {
        delegate?.session(controller: self, didFinishEditing: self.session)
        
        dismissViewController()
    }
    
    @IBAction func pressTrash(_ sender: Any) {
        delegate?.session(controller: self, didDelete: self.session)
        
        dismissViewController()
    }
    
    @IBOutlet weak var textfieldTitle: UITextField!
    @IBOutlet weak var labelTaskTitle: UILabel!
    @IBOutlet weak var labelStartDate: UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    
    private var sessionStartDate: Date {
        set {
            session.startDate = newValue
            datePicker.setDate(newValue, animated: true)
            
            // Start Date
            labelStartDate.text = viewModel.textStartDate
            
            //TODO: RxSwift
            labelEndDate.text = viewModel.textEndDate
            
        }
        get {
            return datePicker.date
        }
    }
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func didChangeDatePicker(_ sender: Any) {
        sessionStartDate = datePicker.date
    }
    
    @IBOutlet weak var labelDuration: UILabel!
    @IBAction func pressMinusDuration(_ sender: Any) {
        
    }
    
    /**
     - warning: newValue is sent as 1.0 as 1 hour and not 3600.0
     
     - returns: duration in the for of hours (e.g. 3,600 is returned as 1.0)
     */
    private var sessionDuration: TimeInterval {
        set {
            sliderDuration.value = Float(newValue)
            
            //TODO: RxSwift
            labelEndDate.text = viewModel.textEndDate
            labelDuration.text = viewModel.textDuration
        }
        get {
            return session.duration
        }
    }
    
    @IBOutlet weak var sliderDuration: UISlider!
    @IBAction func didChangeDurationSlider(_ sender: Any) {
        
        //stepper values
        func rounded(value x: Float) -> Float {
            if x < 0.25 {
                return 0;
            } else if x < 0.5 {
                return 0.25
            } else if x < 1.0 {
                return 0.5
            } else {
                return round(x*2)/2
            }
        }
        
        let newValue = TimeInterval(rounded(value: sliderDuration.value))
        session.duration = newValue
        sessionDuration = newValue
    }
    
    @IBOutlet weak var pressPlusDuration: UIButton!
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
}

extension SessionDetailedController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text != "" {
            session.title = text
        } else {
            session.clearTitle()
            textField.text = session.title
        }
    }
}
