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
    
    var editingMode: CRUD {
        set {
            viewModel.editingMode = newValue
            
            // editingMode can be set before the view is fully loaded thus,
            //check any outlet, that is always set when the view is loaded, and
            //invoke updateUI(..) then
            guard self.buttonLeft != nil else { return }
            
            updateUI(animated: true)
        }
        get {
            return viewModel.editingMode
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
    
    private func dismissViewController(completion handler: @escaping () -> () = {}) {
        self.presentingViewController!.dismiss(animated: true, completion: handler)
    }
    
    private func updateUI(animated: Bool = false) {
        let animationDuration = 0.35
        
        //TODO: update visiblity of the slide down to dismiss

        if editingMode.isCreating {
            isDeleteButtonHidden = true
            isDiscardButtonHidden = false
            buttonLeft.setTitle("Save", for: .normal)
            buttonDiscard.setTitle("Discard", for: .normal)
        } else if editingMode.isReading {
            isDeleteButtonHidden = true
            isDiscardButtonHidden = true
            buttonLeft.setTitle("Edit", for: .normal)
        } else if editingMode.isUpdating {
            isDeleteButtonHidden = false
            isDiscardButtonHidden = false
            buttonLeft.setTitle("Save", for: .normal)
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
        viewModel.saveOnlyOnReading()
    }
    
    // MARK: - IBACTIONS
    
    // MARK: View
    
    //TODO: pan the whole card to dismiss
    @IBAction func didSwipeToDismiss(_ sender: Any) {
        
        // pan to dismiss is only when you are not editing or in the middle of
        //creating a new assignment
        if editingMode.isReading {
            guard viewModel.context.hasChanges == false else {
                fatalError("context should now have any changes, instead, any changes made should be saved automatically")
            }
            
            self.dismissViewController()
        }
    }
    
    @IBOutlet weak var buttonLeft: UIButton!
    @IBAction func pressLeft(_ sender: Any) {
        // Save new Assignment
        if editingMode.isCreating {
            dismiss()
            
            //save
            viewModel.saveNewAssignment()
            self.dismissViewController()
            
        // Save edits
        } else if editingMode.isUpdating {
            isShowingDeadlinePicker = false
            
            //save
            viewModel.saveEdits()
            editingMode = .Read
            
        // Begin edits
        } else if editingMode.isReading {
            
            //begin editing
            viewModel.beginEdits()
            editingMode = .Update
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
    
    private var isDeleteButtonHidden: Bool {
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
    
    private var isDiscardButtonHidden: Bool {
        set {
            // hide the button
            if newValue == true {
                buttonDiscard.setTitleColor(UIColor.clear, for: .normal)
                buttonDiscard.isUserInteractionEnabled = false
                
                // show the button
            } else {
                buttonDiscard.setTitleColor(UIColor.destructive, for: .normal)
                buttonDiscard.isUserInteractionEnabled = true
            }
        }
        get {
            return buttonDiscard.isUserInteractionEnabled.inverse
        }
    }
    
    @IBOutlet weak var buttonDelete: UIButton!
    @IBAction func pressDeleteAssignment(_ sender: Any) {
        viewModel.deleteAssignment()
        self.dismissViewController()
    }
    
    @IBOutlet weak var buttonDiscard: UIButton!
    @IBAction func pressDiscardChanges(_ sender: Any) {
        if editingMode.isCreating {
            self.dismissViewController()
        } else if editingMode.isUpdating {
            viewModel.discardChanges()
            editingMode = .Read
        }
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
        viewModel.saveOnlyOnReading()
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
        viewModel.saveOnlyOnReading()
        
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
        
        let titleCell = UITaskTableViewCell.Types.Basic
        tableTasks.register(titleCell.nib, forCellReuseIdentifier: titleCell.cellIdentifier)
        
        //TODO: Dynamic Font, user preferences of which cell to display
        tableTasks.rowHeight = 32
        
        //FIXME: RxSwift, rename method to viewDidLoad()
        self.updateUI()
        
        self.isShowingPriorityBox = false
    }
}

extension AssignmentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedAssignmentTasks?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITaskTableViewCell.Types.Basic.cellIdentifier) as! UITaskTableViewCell? else {
            assertionFailure("TaskTableViewCell was not registered")
            
            return UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        guard let tasks = viewModel.fetchedAssignmentTasks else {
            fatalError("ooh shit, fetchrequest controller not set")
        }
        
        let task = tasks.task(at: indexPath)
        cell.configure(task)
        cell.delegate = self
        
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

extension AssignmentViewController: UITaskTableViewCellDelegate {
    func task(cell: UITaskTableViewCell, didTapCheckBox newState: Bool) {
        guard
            let tasks = viewModel.fetchedAssignmentTasks,
            let indexPath = tableTasks.indexPath(for: cell)
            else {
            fatalError("ooh shit, fetchrequest controller not set")
        }
        
        let task = tasks.task(at: indexPath)
        task.isCompleted = newState
        viewModel.saveOnlyOnReading()
    }
}

extension UIStoryboardSegue {
    static var ShowDetailedAssignment = "show detailed assignment"
}
