//
//  AssignmentViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/10/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CoreData

class AssignmentViewController: UIViewController, UITextFieldDelegate {
    
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
    
    var editingMode: CRUD = .Create {
        didSet {
            // editingMode can be set before the view is fully loaded thus,
            //check any outlet, that is always set when the view is loaded, and
            //invoke updateUI(..) then
            guard self.buttonLeft != nil else { return }
            
            updateUI(animated: true)
        }
    }
    
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
    
    // MARK: Text Field
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textfieldTitle {
            textfieldTitle.resignFirstResponder()
        }
        
        return false
    }
    
    // MARK: - VOID METHODS
    
    private func dismiss() {
        if textfieldTitle.isFirstResponder {
            textfieldTitle.resignFirstResponder()
        }
    }
    
    private func updateUI(animated: Bool = false) {
        let animationDuration = 0.35
        
        //TODO: update visiblity of the slide down to dismiss

        if editingMode.isCreating {
            isTrashButtonHidden = false
            buttonLeft.setTitle("Save", for: .normal)
            buttonDelete.setTitle("Discard", for: .normal)
        } else if editingMode.isReading {
            isTrashButtonHidden = true
            buttonLeft.setTitle("Edit", for: .normal)
        } else if editingMode.isUpdating {
            isTrashButtonHidden = false
            buttonLeft.setTitle("Done", for: .normal)
        }
        
        // Update assignment properties
        
        //TODO: RxSwift
        buttonCheckbox.isChecked = assignment.isCompleted
        imagePriorityBox.priority = assignment.priority
        textfieldTitle.text = assignment.title
        buttonBreadcrum.setTitle(viewModel.parentTitle, for: .normal)
        labelDeadlineSubtext.text = viewModel.deadlineSubtext
        
        if editingMode.isReading {
            buttonDeadline.setTitle(viewModel.deadlineTitle ?? "no deadline", for: .normal)
        } else if editingMode.isCreating || editingMode.isUpdating {
            buttonDeadline.setTitle(viewModel.deadlineTitle ?? "Add a Deadline", for: .normal)
        }
        
        let showEffortSliderAnimations = { [unowned self] in
            self.viewEffortValues.isHidden = true
            self.viewEffortValues.alpha = 0.0
            self.viewEffortSlider.isHidden = false
            self.viewEffortSlider.alpha = 1.0
        }
        
        let showEffortValuesAnimations = { [unowned self] in
            self.viewEffortValues.isHidden = false
            self.viewEffortValues.alpha = 1.0
            self.viewEffortSlider.isHidden = true
            self.viewEffortSlider.alpha = 0.0
        }
        
        // edit assignment properties
        if self.editingMode.isUpdating || self.editingMode.isCreating {
            buttonDeadline.setTitleColor(.buttonTint, for: .normal)
            buttonDeadline.isUserInteractionEnabled = true
            
            if animated {
                UIView.animate(withDuration: animationDuration, animations: showEffortSliderAnimations)
            } else {
                showEffortSliderAnimations()
            }
            effortSliderValue = assignment.effort
            
        // reading only
        } else if self.editingMode.isReading {
            buttonDeadline.setTitleColor(.black, for: .normal)
            buttonDeadline.isUserInteractionEnabled = false
            
            if animated {
                UIView.animate(withDuration: animationDuration, animations: showEffortValuesAnimations)
            } else {
                showEffortValuesAnimations()
            }
            
            //TODO: update the effort chart
        }
        
        // Fetch tasks
        tableTasks.reloadData()
    }
    
    // MARK: Text Field
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        assignment.title = textField.text
    }
    
    // MARK: - IBACTIONS
    
    // MARK: View
    
    @IBAction func didSwipeToDismiss(_ sender: Any) {
        //TODO: pan the whole card to dismiss
        
        // pan to dismiss is only when you are not editing or in the middle of
        //creating a new assignment
        if editingMode.isReading {
            self.presentingViewController!.dismiss(animated: true)
        }
    }
    
    @IBOutlet weak var buttonLeft: UIButton!
    @IBAction func pressEdit(_ sender: Any) {
        if editingMode.isCreating {
            dismiss()
            //TODO: save temp context into main context and onto disk
            PersistenceStack.shared.saveContext()
            self.presentingViewController!.dismiss(animated: true)
        } else if editingMode.isUpdating {
            //TODO: save temp context into main context and onto disk
            isShowingDeadlinePicker = false
            editingMode = .Read
        } else if editingMode.isReading {
            editingMode = .Update
        }
    }
    
    @IBOutlet weak var buttonDelete: UIButton!
    @IBAction func pressDeleteAssignment(_ sender: Any) {
        
    }
    
    // MARK: Title and breadcrum
    
//    var isAssignmentCompleted: Bool {
//        set {
//            if newValue {
//                buttonCheckbox.setImage(UIImage.assignmentCheckboxCompleted, for: .normal)
//            } else {
//                buttonCheckbox.setImage(UIImage.assignmentCheckbox, for: .normal)
//            }
//
//            assignment.isCompleted = newValue
//        }
//        get {
//            return assignment.isCompleted
//        }
//    }
    
    @IBOutlet weak var buttonCheckbox: UICheckbox!
    @IBAction func pressCheckbox(_ sender: Any) {
        //TODO: control stored property by class itself by sending custom 'Send Event'
        buttonCheckbox.isChecked.invert()
        
        //TODO: RxSwift
        assignment.isCompleted = buttonCheckbox.isChecked
    }
    
    var isShowingPriorityBox: Bool {
        set {
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.viewPriorityBox.isHidden = newValue.inverse
                self.viewPriorityBox.alpha = newValue ? 1.0 : 0.0
            }
        }
        get {
            return viewPriorityBox.isHidden.inverse
        }
    }
    
    @IBOutlet weak var viewPriorityBox: UIView!
    
    @IBAction func pressPriorityBox(_ sender: Any) {
        isShowingPriorityBox.invert()
    }
    
    @IBOutlet weak var imagePriorityBox: UIPriorityBox!
    @IBAction func pressA_Priority(_ sender: UIButton) {
        guard let newPriority = Assignment.Priorities(rawValue: sender.tag) else {
            fatalError("setting a priority to an unsupported button.tag value")
        }
        
        viewModel.setPriority(to: newPriority)
        
        //TODO: RxSwift
        imagePriorityBox.priority = newPriority
        
        isShowingPriorityBox = false
    }
    
    @IBOutlet weak var buttonBreadcrum: UIButton!
    @IBAction func pressBreadcrum(_ sender: Any) {
        
    }
    
    // MARK: Deadline
    
    @IBOutlet weak var buttonDeadline: UIButton!
    @IBAction func pressDeadline(_ sender: Any) {
        if self.isShowingDeadlinePicker {
            self.isShowingDeadlinePicker = false
        } else {
            if assignment.deadline == nil {
                viewModel.setDeadlineToToday()
                
                //TODO: RxSwift
                buttonDeadline.setTitle(viewModel.deadlineTitle!, for: .normal)
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
        
        //TODO: RxSwift
        buttonDeadline.setTitle("Add a Deadline", for: .normal)
    }
    
    @IBAction func pressApplyDeadline(_ sender: Any) {
        self.isShowingDeadlinePicker = false
    }
    
    // MARK: Effort Slider
    
    @IBOutlet weak var labelEffort: UILabel!
    /**
     the effort slider's max values flexes when the user taps on the add
     effort button and reduces when the user slides below 4; min
     is 6
     */
    var maxEffortValue = 6 {
        didSet {
            sliderEffort.maximumValue = Float(maxEffortValue)
        }
    }
    
    @IBOutlet weak var viewEffortSlider: UIView!
    @IBOutlet weak var sliderEffort: UISlider!
    
    /** Protected accessor to slider.value when reading and setting */
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
        
        self.isShowingPriorityBox = false
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
