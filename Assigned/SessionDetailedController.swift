//
//  SessionViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/20/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class SessionDetailedController: UIViewController {
    
    var viewModel = SessionDetailedViewModel()
    
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
    
    // MARK: - IBACTIONS
    
    @IBAction func pressDone(_ sender: Any) {
        
    }
    
    @IBAction func pressTrash(_ sender: Any) {
        
    }
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelTaskTitle: UILabel!
    @IBOutlet weak var labelDateRanges: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func didChangeDatePicker(_ sender: Any) {
        
    }
    
    @IBOutlet weak var labelDuration: UILabel!
    @IBAction func pressMinusDuration(_ sender: Any) {
        
    }
    
    @IBOutlet weak var sliderDuration: UISlider!
    @IBAction func didChangeDurationSlider(_ sender: Any) {
        
    }
    
    @IBOutlet weak var pressPlusDuration: UIButton!
    
    // MARK: - LIFE CYCLE

}
