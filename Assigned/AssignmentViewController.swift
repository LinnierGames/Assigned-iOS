//
//  AssignmentViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/10/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CoreData

class AssignmentViewController: UIViewController {
    
    @IBOutlet weak var textfieldTitle: UITextField!
    @IBOutlet weak var labelDeadlineSubtext: UILabel!
    @IBOutlet weak var tableTasks: UITableView!
    @IBOutlet weak var viewEffortValues: UIStackView!
    
    private lazy var viewModel = AssignmentViewModel(with: self)
    
    var assignment: Assignment {
        get {
            return viewModel.assignment
        }
        set {
            viewModel.assignment = newValue
        }
    }
    
    var editingMode: CRUD = .Create
    
    private var isShowingDeadlinePicker: Bool {
        set {
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.viewDeadlinePicker.isHidden = newValue.inverse
                if newValue == false {
                    self.viewDeadlinePicker.alpha = 0.0
                } else {
                    self.viewDeadlinePicker.alpha = 1.0
                }
            }
        }
        get {
            return viewDeadlinePicker.isHidden.inverse
        }
    }
    
    private var isTrashButtonHidden: Bool {
        set {
            // hide the button
            if newValue == true {
                buttonDelete.setTitleColor(UIColor.clear, for: .normal)
                buttonDelete.isUserInteractionEnabled = false
                
            // show the button
            } else {
                buttonDelete.setTitleColor(UIColor.destructive, for: .normal)
                buttonDelete.isUserInteractionEnabled = true
            }
        }
        get {
            return buttonDelete.isUserInteractionEnabled.inverse
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI(animated: Bool = false) {
        
        // Update assignment properties
        buttonBreadcrum.setTitle(viewModel.parentTitle, for: .normal)
        textfieldTitle.text = assignment.title
        labelDeadlineSubtext.text = viewModel.deadlineSubtext
        buttonDeadline.setTitle(viewModel.deadlineTitle, for: .normal)
        
        
        // edit assignment properties
        if self.editingMode.isEditing || self.editingMode.isCreating {
            buttonDeadline.setTitleColor(.buttonTint, for: .normal)
            
            viewEffortValues.isHidden = true
            viewEffortSlider.isHidden = false
            effortSliderValue = assignment.effort
            isTrashButtonHidden = false
            
        // reading only
        } else if self.editingMode.isReading {
            buttonDeadline.setTitleColor(.black, for: .normal)
            
            viewEffortValues.isHidden = false
            viewEffortSlider.isHidden = true
            isTrashButtonHidden = true
        }
        
        // Fetch tasks
        tableTasks.reloadData()
    }
    
    // MARK: - IBACTIONS
    
    @IBAction func pressEdit(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBOutlet weak var buttonDelete: UIButton!
    @IBAction func pressDeleteAssignment(_ sender: Any) {
        
    }
    
    
    @IBOutlet weak var buttonCheckbox: UIButton!
    @IBAction func pressCheckbox(_ sender: Any) {
        
    }
    
    @IBOutlet weak var buttonBreadcrum: UIButton!
    @IBAction func pressBreadcrum(_ sender: Any) {
        
    }
    
    @IBOutlet weak var buttonDeadline: UIButton!
    @IBAction func pressDeadline(_ sender: Any) {
        if self.isShowingDeadlinePicker {
            self.isShowingDeadlinePicker = false
        } else {
            if assignment.deadline == nil {
                viewModel.setDeadlineToToday()
            }
            
            self.isShowingDeadlinePicker = true
        }
    }
    
    @IBOutlet weak var viewDeadlinePicker: UIStackView!
    @IBOutlet weak var deadlinePicker: UIDatePicker!
    @IBAction func didChangeDeadline(_ sender: Any) {
        let newDate = deadlinePicker.date
        viewModel.updateDeadline(to: newDate)
        
        //TODO: RxSwift
        buttonDeadline.setTitle(viewModel.deadlineTitle, for: .normal)
    }
    
    @IBAction func pressRemoveDeadline(_ sender: Any) {
        //TODO: RxSwift
        viewModel.updateDeadline(to: nil)
        self.isShowingDeadlinePicker = false
    }
    
    @IBAction func pressApplyDeadline(_ sender: Any) {
        self.isShowingDeadlinePicker = false
    }
    
    // MARK: Effort Slider
    
    @IBOutlet weak var labelEffort: UILabel!
    /**
     the effort slider's max values flexes when the user taps on the add
     effort button and reduces when the user slides below half of the max; min
     is 15
     */
    var maxEffortValue = 8 {
        didSet {
            sliderEffort.maximumValue = Float(maxEffortValue)
        }
    }
    
    @IBOutlet weak var viewEffortSlider: UIView!
    @IBOutlet weak var sliderEffort: UISlider!
    
    /** Protected accessor to slider.value when reading and setting  */
    private var effortSliderValue: Float {
        set {
            let newSliderValue: Float
            
            if newValue <= 0 {
                newSliderValue = 0.0
                labelEffort.text = "no effort"
            } else {
                if newValue > Float(maxEffortValue) {
                    maxEffortValue = Int(newValue) // max effort are only represent whole hours
                }
                newSliderValue = newValue
                
                let nHours = TimeInterval(newSliderValue) * CTDateComponentHour
                labelEffort.text = String(timeInterval: nHours, options: .hour, .minute)
            }
            
            sliderEffort.value = newSliderValue
            assignment.effort = newSliderValue
        }
        get {
            return sliderEffort.value
        }
    }
    
    @IBAction func didChangeEffortSlider(_ sender: UISlider) {
        
        //stepper values
        func rounded(value x: Float) -> Float {
            if x < 0.25 {
                return 0;
            } else if x < 0.5 {
                return 0.25
            } else if x < 1.0 {
                return 0.5
            } else {
                return round(x)
            }
        }
        
        effortSliderValue = rounded(value: sender.value)
        
        //FIXME: reducing the max value while dragging creates a glitchy drag
        if effortSliderValue < 4 {
            maxEffortValue = 8
        }
    }
    
    @IBAction func pressSubtractEffort(_ sender: Any) {
        effortSliderValue -= 1
    }
    
    @IBAction func pressAddEffort(_ sender: Any) {
        effortSliderValue += 1
    }
    
    
    // MARK: Tasks
    
    @IBAction func pressAddTask(_ sender: Any) {
        let alertAddTitle = UIAlertController(
            title: "Add a Task",
            message: "enter a title",
            preferredStyle: .alert
        )
        
        alertAddTitle
            .addTextField()
            .addCancelButton()
            .addButton(title: "Add") { [unowned self] (action) in
                if let newTitle = alertAddTitle.inputField.text {
                    self.viewModel.addTask(with: newTitle)
                }
            }
            .present(in: self)
        
    }
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableTasks.register(UINib.assignmentTaskCells(), forCellReuseIdentifier: UITaskTableViewCell.Types.basic)
        
        //TODO: Dynamic Font, user preferences of which cell to display
        tableTasks.rowHeight = 32
        
        //FIXME: RxSwift, rename method to viewDidLoad()
        self.updateUI()
    }
}

extension AssignmentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.assignmentTasks?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITaskTableViewCell.Types.basic) as! UITaskTableViewCell? else {
            assertionFailure("TaskTableViewCell was not registered")
            
            return UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        guard let tasks = viewModel.assignmentTasks else {
            fatalError("ooh shit")
        }
        
        let task = tasks.task(at: indexPath)
        cell.configure(task)
        
        return cell
    }
    
    
}

extension AssignmentViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableTasks.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableTasks.insertSections([sectionIndex], with: .fade)
        case .delete: tableTasks.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableTasks.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableTasks.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableTasks.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableTasks.deleteRows(at: [indexPath!], with: .fade)
            tableTasks.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableTasks.endUpdates()
    }
}

extension UIStoryboardSegue {
    static var ShowDetailedAssignment = "show detailed assignment"
}
