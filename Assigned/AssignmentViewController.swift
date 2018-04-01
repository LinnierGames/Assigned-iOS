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

    private lazy var viewModel: AssignmentViewModel = {
        guard let model = self.parentNavigationViewController?.viewModel else {
            fatalError("parent navigation view controller was not set")
        }
        
        return AssignmentViewModel(with: model, delegate: self)
    }()

    var dataModel: AssignmentNavigationViewModel {
        return self.viewModel.parentModel
    }

    weak var parentNavigationViewController: AssignmentNavigationViewController?

    var assignment: Assignment {
        return viewModel.assignment
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show move":
                guard
                    let navVc = segue.destination as? UINavigationController,
                    let moveVc = navVc.topViewController! as? MoveViewController
                    else {
                        fatalError("MoveTableViewController was not set in storyboard")
                }

                moveVc.item = assignment
                moveVc.delegate = self
            default: break
            }
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
        
        if dataModel.editingMode.isReading, dataModel.context.hasChanges == true {
            fatalError("unsaved changes during dismissing on reading")
        }

        setViewState(to: .Hidden, animated: true) { [unowned self] in
            self.presentingViewController!.dismiss(animated: true, completion: handler)
        }
    }

    private func updateUI(animated: Bool = false) {
        let animationDuration = 0.35

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
            effortSliderValue = assignment.duration
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
            viewEffortCompleted.duration = assignment.completedDurationOfSessions
            viewEffortPlanned.duration = assignment.plannedDurationOfSessions
            viewEffortUnplanned.duration = assignment.unplannedDuration
            print(assignment.completedDurationOfSessions, assignment.plannedDurationOfSessions, assignment.unplannedDuration, assignment.durationValue)
            viewEffortTotal.duration = assignment.durationValue
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
            dataModel.saveNewAssignment()
            self.dismissViewController()

        // Save edits
        } else if editingMode.isUpdating {
            dismiss()

            //save
            dataModel.saveEdits()
            editingMode = .Read

        // Begin edits
        } else if editingMode.isReading {
            dismiss()

            //begin editing
            dataModel.beginEdits()
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
            buttonDelete.isHidden = newValue
//            // hide the button
//            if newValue == true {
//                buttonDelete.isHidden = true
//                buttonDelete.isUserInteractionEnabled = false
//
//                // show the button
//            } else {
//                buttonDelete.setTitleColor(UIColor.destructive, for: .normal)
//                buttonDelete.isUserInteractionEnabled = true
//            }
        }
        get {
            return buttonDelete.isHidden
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
        dataModel.deleteAssignment()
        self.dismissViewController()
    }

    @IBOutlet weak var buttonDiscard: UIButton!
    @IBAction func pressDiscardChanges(_ sender: Any) {
        if editingMode.isCreating {
            self.dismissViewController()
        } else if editingMode.isUpdating {
            self.dismiss()
            dataModel.discardChanges()
            editingMode = .Read
        }
    }

    // MARK: Title and breadcrum

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
        dataModel.saveOnlyOnReading()
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
        dataModel.saveOnlyOnReading()

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

            // can't be smaller than zero
            if newValue <= 0 {
                newSliderValue = 0.0
            } else {
                newSliderValue = newValue
                
                // update the slider's max value?
                if newValue > Float(maxEffortValue) {
                    maxEffortValue = Int(newValue) // max effort are only represent whole hours
                }
            }
            
            // update slider and assignment
            sliderEffort.value = newSliderValue
            assignment.duration = newSliderValue
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
                    self.dataModel.addTask(with: newTitle)
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let task = viewModel.fetchedAssignmentTasks.task(at: indexPath)
            dataModel.delete(task: task)
            dataModel.saveOnlyOnReading()
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
            return assertionFailure("index path for cell not found")
        }

        let task = viewModel.fetchedAssignmentTasks.task(at: indexPath)
        task.isCompleted = newState
        dataModel.saveOnlyOnReading()
    }

    func task(cell: UITaskTableViewCell, didChangeTask task: Task, to newTitle: String) {
        task.title = newTitle
        dataModel.saveOnlyOnReading()
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
                dataModel.addTask(with: newTitle)
                textfieldAddTasks.text = ""
            } else {
                textfieldAddTasks.resignFirstResponder()
            }
        }

        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === textfieldTitle {
            if let text = textField.text {
                assignment.title = text
                dataModel.saveOnlyOnReading()
            }
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
        }
    }
}

extension AssignmentViewController: MoveViewControllerDelegate {

    func move(viewController: MoveViewController, didMove item: DirectoryInfo, to destination: DirectoryInfo?) {
        //TODO: RxSwift
        buttonBreadcrum.setTitle(viewModel.parentTitle, for: .normal)
        dataModel.saveOnlyOnReading()
    }
}

extension UIStoryboardSegue {
    static var ShowDetailedAssignment = "show detailed assignment"
}
