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
    
    private enum ViewStates {
        case Hidden
        case Presented
    }
    
    private var viewState: ViewStates = .Hidden
    
    private let TOP_MARGIN = CGFloat(48.0)
    private let BOTTOM_MARGIN = CGFloat(58.0)
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    var assignmentParentDirectory: Directory? {
        set {
            
            // fetch the same parent in the different context
            if let parent = newValue {
                let newParent = viewModel.context.object(with: parent.objectID) as! Directory
                assignment.parent = newParent
            } else {
                assignment.parent = nil
            }
        }
        get {
            return assignment.parent
        }
    }
    
    private func setViewState(to newValue: ViewStates, animated: Bool, completion: (() -> Void)? = nil) {
        viewState = newValue
        guard let screenSize = AppDelegate.shared.window?.bounds.size
            else {
                fatalError("no app delegate window")
        }
        
        let animationBlock: () -> Void
        let animationCurve: UIViewAnimationOptions
        
        switch viewState {
        case .Hidden:
            animationBlock = { [weak self] in
                self?.constraintCardTopMargin.constant = screenSize.height
                self?.view.layoutIfNeeded()
            }
            animationCurve = .curveEaseOut
        case .Presented:
            animationBlock = { [weak self] in
                guard let unwrappedSelf = self else { return }
                
                unwrappedSelf.constraintCardTopMargin.constant = unwrappedSelf.TOP_MARGIN
                unwrappedSelf.view.layoutIfNeeded()
            }
            animationCurve = .curveEaseIn
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: animationCurve, animations: animationBlock, completion: { _ in
                completion?()
            })
        } else {
            animationBlock()
            completion?()
        }
    }
    
    private func dismiss() {
        dismissKeyboardOnly()
        dismissPickersOnly()
    }
    
    private func dismissKeyboardOnly() {
        if textfieldTitle.isFirstResponder {
            textfieldTitle.resignFirstResponder()
        }
    }
    
    private func dismissPickersOnly() {
        isShowingDeadlinePicker = false
        isShowingPriorityBox = false
    }
    
    private func dismissViewController(completion handler: @escaping () -> () = {}) {
        dismiss()
        
        setViewState(to: .Hidden, animated: true) { [unowned self] in
            self.presentingViewController!.dismiss(animated: true, completion: handler)
        }
    }
    
    private func updateUI(animated: Bool = false) {
        let animationDuration = 0.35
        
        //TODO: update visiblity of the slide down to dismiss

        if editingMode.isCreating {
            isDeleteButtonHidden = true
            isDiscardButtonHidden = false
            isShowingTasksTable = true
            buttonLeft.setTitleWithoutAnimation("Save", for: .normal)
        } else if editingMode.isReading {
            isDeleteButtonHidden = true
            isDiscardButtonHidden = true
            isShowingTasksTable = true
            buttonLeft.setTitleWithoutAnimation("Edit", for: .normal)
        } else if editingMode.isUpdating {
            isDeleteButtonHidden = false
            isDiscardButtonHidden = false
            isShowingTasksTable = false
            buttonLeft.setTitleWithoutAnimation("Save", for: .normal)
        }
        
        // Update assignment properties
        
        //TODO: RxSwift
        textfieldTitle.text = assignment.title
        buttonCheckbox.isChecked = assignment.isCompleted
        imagePriorityBox.priority = assignment.priority
        buttonBreadcrum.setTitleWithoutAnimation(viewModel.parentTitle, for: .normal)
        labelDeadlineSubtext.text = viewModel.deadlineSubtext
        deadlinePicker.date = assignment.deadline ?? Date()
        
        if editingMode.isReading {
            buttonDeadline.setTitleWithoutAnimation(viewModel.deadlineTitle ?? "no deadline", for: .normal)
        } else if editingMode.isCreating || editingMode.isUpdating {
            buttonDeadline.setTitleWithoutAnimation(viewModel.deadlineTitle ?? "Add a Deadline", for: .normal)
        }
        
        //TODO: DRY
        let showEffortSliderAnimations = { [unowned self] in
            self.viewEffortValues.isHidden = true
            self.viewEffortValues.alpha = 0.0
            self.viewEffortSlider.isHidden = false
            self.viewEffortSlider.alpha = 1.0
            
            self.imageDraggable.alpha = 0.0
        }
        
        let showEffortValuesAnimations = { [unowned self] in
            self.viewEffortValues.isHidden = false
            self.viewEffortValues.alpha = 1.0
            self.viewEffortSlider.isHidden = true
            self.viewEffortSlider.alpha = 0.0
            
            self.imageDraggable.alpha = 1.0
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
            labelEffort.text = viewModel.effortTitle
            
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
//            viewEffortCompleted.duration =
//            viewEffortPlanned.duration =
//            viewEffortUnplanned.duration =
            viewEffortTotal.duration = TimeInterval(assignment.effortValue)
            labelEffort.text = nil
        }
        
        // Fetch tasks
        tableTasks.reloadData()
    }
    
    // MARK: - IBACTIONS
    
    // MARK: View
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var constraintCardTopMargin: NSLayoutConstraint!
    
    @IBOutlet weak var imageDraggable: UIImageView!
    
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
            dismiss()
            
            //save
            viewModel.saveEdits()
            editingMode = .Read
            
        // Begin edits
        } else if editingMode.isReading {
            dismiss()
            
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
            self.dismiss()
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
    
    @IBOutlet weak var textfieldTitle: UIValidatedTextField! {
        didSet {
            textfieldTitle.resultValidation = UIValidatedTextField.Validations.cannotBeEmpty
        }
    }
    
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
    @IBOutlet weak var labelDeadlineSubtext: UILabel!
    
    @IBOutlet weak var buttonDeadline: UIButton!
    @IBAction func pressDeadline(_ sender: Any) {
        if self.isShowingDeadlinePicker {
            self.isShowingDeadlinePicker = false
        } else {
            if assignment.deadline == nil {
                viewModel.setDeadlineToToday()
                
                //TODO: RxSwift
                buttonDeadline.setTitle(viewModel.deadlineTitle!, for: .normal)
                labelDeadlineSubtext.text = viewModel.deadlineSubtext
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
        labelDeadlineSubtext.text = viewModel.deadlineSubtext
    }
    
    @IBAction func pressRemoveDeadline(_ sender: Any) {
        //TODO: RxSwift
        viewModel.updateDeadline(to: nil)
        self.isShowingDeadlinePicker = false
        
        //TODO: RxSwift
        buttonDeadline.setTitle("Add a Deadline", for: .normal)
        labelDeadlineSubtext.text = viewModel.deadlineSubtext
    }
    
    @IBAction func pressApplyDeadline(_ sender: Any) {
        self.isShowingDeadlinePicker = false
    }
    
    // MARK: Effort View
    
    @IBOutlet weak var viewEffortValues: UIStackView!
    
    @IBOutlet weak var viewEffortCompleted: UITimeBox!
    @IBOutlet weak var viewEffortPlanned: UITimeBox!
    @IBOutlet weak var viewEffortUnplanned: UITimeBox!
    @IBOutlet weak var viewEffortTotal: UITimeBox!
    
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
            } else {
                if newValue > Float(maxEffortValue) {
                    maxEffortValue = Int(newValue) // max effort are only represent whole hours
                }
                newSliderValue = newValue
            }
            
            sliderEffort.value = newSliderValue
            assignment.effort = newSliderValue
            labelEffort.text = viewModel.effortTitle
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
                return round(x*2)/2
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
    
    @IBOutlet weak var viewTasks: UIStackView!
    @IBOutlet weak var viewNonTasks: UIView!
    @IBOutlet weak var tableTasks: UITableView!
    @IBOutlet weak var textfieldAddTasks: UITextField!
    
    private var isShowingTasksTable: Bool {
        set {
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.viewTasks.isHidden = newValue.inverse
                if newValue == false {
                    self.viewTasks.alpha = 0.0
                } else {
                    self.viewTasks.alpha = 1.0
                }
            }
            self.viewNonTasks.isHidden = newValue
        }
        get {
            return viewTasks.isHidden.inverse
        }
    }
    
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
        
        let titleCell = UITaskTableViewCell.Types.Textfield
        tableTasks.register(titleCell.nib, forCellReuseIdentifier: titleCell.cellIdentifier)
        
        //TODO: Dynamic Font, user preferences of which cell to display
        tableTasks.rowHeight = 44
        
        viewEffortTotal.calendarUnits = [.day, .hour, .minute]
        
        // set card at the bottom and animate to the top
        setViewState(to: .Hidden, animated: false)
        
        //FIXME: RxSwift, rename method to viewDidLoad()
        self.updateUI()
        
        self.isShowingPriorityBox = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // animate to presented
        setViewState(to: .Presented, animated: true, completion: { [unowned self] in
            self.theViewDidAppear(animated)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     */
    private func theViewDidAppear(_ animated: Bool) {
        
        // present the keyboard on new assignments
        if editingMode.isCreating {
            textfieldTitle.becomeFirstResponder()
        }
    }
}

extension AssignmentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedAssignmentTasks.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITaskTableViewCell.Types.Textfield.cellIdentifier) as! UITaskTableViewCell? else {
            assertionFailure("TaskTableViewCell was not registered")
            
            return UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        let task = viewModel.fetchedAssignmentTasks.task(at: indexPath)
        cell.configure(task)
        cell.delegate = self
        
        return cell
    }
}


extension AssignmentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            viewModel.deleteTask(at: indexPath)
            viewModel.saveOnlyOnReading()
        default: break
        }
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
            let indexPath = tableTasks.indexPath(for: cell)
            else {
            fatalError("ooh shit, fetchrequest controller not set")
        }
        
        let task = viewModel.fetchedAssignmentTasks.task(at: indexPath)
        task.isCompleted = newState
        viewModel.saveOnlyOnReading()
    }
    
    func task(cell: UITaskTableViewCell, didChangeTask task: Task, to newTitle: String?) {
        task.title = newTitle
        viewModel.saveOnlyOnReading()
    }
}

extension AssignmentViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === textfieldTitle {
            
            //TODO: validation
            textfieldTitle.resignFirstResponder()
        } else if textField === textfieldAddTasks {
            textfieldTitle.resignFirstResponder()
            
            // is empty?
            if let newTitle = textfieldAddTasks.text, newTitle != "" {
                viewModel.addTask(with: newTitle)
                textfieldAddTasks.text = ""
            } else {
                textfieldAddTasks.resignFirstResponder()
            }
        }
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === textfieldTitle {
            assignment.title = textField.text
            viewModel.saveOnlyOnReading()
        }
    }
    
}

extension AssignmentViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboardOnly()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard editingMode.isReading else { return }
        if scrollView.contentOffset.y < -48 {
            
            self.dismissViewController()
            
//            // dismiss the card
//            UIView.animate(withDuration: 0.25) {
//                self.constraintCardTopMargin.constant = self.view.frame.size.height
//                self.view.layoutIfNeeded()
//            }
//
        }
    }
}

extension UIStoryboardSegue {
    static var ShowDetailedAssignment = "show detailed assignment"
}
