//
//  TaskViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/10/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UIViewController {

    private lazy var viewModel: TaskViewModel = {
        guard let model = self.parentNavigationViewController?.viewModel else {
            fatalError("parent navigation view controller was not set")
        }
        
        return TaskViewModel(with: model, delegate: self)
    }()

    var dataModel: TaskNavigationViewModel {
        return self.viewModel.parentModel
    }

    weak var parentNavigationViewController: TaskNavigationViewController?

    var task: Task {
        return viewModel.task
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

    // MARK: - RETURN VALUES

    // MARK: - VOID METHODS

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case UIStoryboardSegue.showMove:
                guard
                    let navVc = segue.destination as? UINavigationController,
                    let moveVc = navVc.topViewController! as? MoveViewController
                    else {
                        fatalError("MoveTableViewController was not set in storyboard")
                }

                moveVc.items = [task.directory]
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

                unwrappedSelf.constraintCardTopMargin.constant = TaskNavigationViewController.TOP_MARGIN
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
        } else if textfieldAddSubtasks.isFirstResponder {
            textfieldAddSubtasks.resignFirstResponder()
        }
    }

    private func dismissPickersOnly() {
        isShowingDeadlinePicker = false
        isShowingPriorityBox = false
    }

    private func dismissViewController(completion handler: @escaping () -> () = {}) {
        dismiss()
        
        if dataModel.editingMode.isReading, dataModel.context.hasChanges == true {
            //TODO: remove fatal error
            debugPrint("fatalError(\"unsaved changes during dismissing on reading\")")
            self.dataModel.save()
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
            isShowingSubtasksTable = true
            buttonLeft.setTitleWithoutAnimation("Save", for: .normal)
            buttonLeft.layer.borderColor = UIColor.buttonTint.cgColor
        } else if editingMode.isReading {
            isDeleteButtonHidden = true
            isDiscardButtonHidden = true
            isShowingSubtasksTable = true
            buttonLeft.setTitleWithoutAnimation("Edit", for: .normal)
            buttonLeft.layer.borderColor = UIColor.buttonTint.cgColor
        } else if editingMode.isUpdating {
            isDeleteButtonHidden = false
            isDiscardButtonHidden = false
            isShowingSubtasksTable = false
            buttonLeft.setTitleWithoutAnimation("Save", for: .normal)
            buttonLeft.layer.borderColor = UIColor.buttonTint.cgColor
        }

        // Update task properties

        //TODO: RxSwift
        textfieldTitle.text = task.title
        buttonCheckbox.isChecked = task.isCompleted
        imagePriorityBox.priority = task.priority
        self.updateProrityButtons()
        
        buttonBreadcrum.setTitleWithoutAnimation(viewModel.parentTitle, for: .normal)
        labelDeadlineSubtext.text = viewModel.deadlineSubtext
        deadlinePicker.date = task.deadline ?? Date()

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
            self.viewCard.layoutIfNeeded()
        }

        let showEffortValuesAnimations = { [unowned self] in
            self.viewEffortValues.isHidden = false
            self.viewEffortValues.alpha = 1.0
            self.viewEffortSlider.isHidden = true
            self.viewEffortSlider.alpha = 0.0

            self.imageDraggable.alpha = 1.0
            self.viewCard.layoutIfNeeded()
        }

        // edit task properties
        if self.editingMode.isUpdating || self.editingMode.isCreating {
            buttonDeadline.setTitleColor(.buttonTint, for: .normal)
            buttonDeadline.isUserInteractionEnabled = true

            if animated {
                UIView.animate(withDuration: animationDuration, animations: showEffortSliderAnimations)
            } else {
                showEffortSliderAnimations()
            }
            effortSliderValue = task.duration
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

            viewEffortCompleted.duration = task.completedDurationOfSessions
            viewEffortPlanned.duration = task.plannedDurationOfSessions
            
            // Hide the unplanned section if no duration is set
            if task.duration <= 0 {
                viewEffortUnplanned.isHidden = true
                viewEffortTotal.isHidden = true
            } else {
                viewEffortUnplanned.isHidden = false
                viewEffortTotal.isHidden = false
                viewEffortUnplanned.duration = task.unplannedDuration
            }
            print(task.completedDurationOfSessions, task.plannedDurationOfSessions, task.unplannedDuration, task.durationValue)
            viewEffortTotal.duration = task.durationValue
            labelEffort.text = nil
        }

        // Fetch subtasks
        tableSubtasks.reloadData()
        self.updateSubtaskTableLength()
    }
    
    private func updateProrityButtons() {
        switch self.task.priority {
        case .Low:
            buttonLowPriority.layer.roundedShape(cornerRadius: 4.0, backgroundColor: UIColor.buttonTint)
            buttonLowPriority.tintColor = .white
            buttonMediumPriority.layer.clear()
            buttonMediumPriority.tintColor = .buttonTint
            buttonHighPriority.layer.clear()
            buttonHighPriority.tintColor = .buttonTint
            buttonNonePriority.layer.clear()
            buttonNonePriority.tintColor = .buttonTint
        case .Medium:
            buttonLowPriority.layer.clear()
            buttonLowPriority.tintColor = .buttonTint
            buttonMediumPriority.layer.roundedShape(cornerRadius: 4.0, backgroundColor: UIColor.buttonTint)
            buttonMediumPriority.tintColor = .white
            buttonHighPriority.layer.clear()
            buttonHighPriority.tintColor = .buttonTint
            buttonNonePriority.layer.clear()
            buttonNonePriority.tintColor = .buttonTint
        case .High:
            buttonLowPriority.layer.clear()
            buttonLowPriority.tintColor = .buttonTint
            buttonMediumPriority.layer.clear()
            buttonMediumPriority.tintColor = .buttonTint
            buttonHighPriority.layer.roundedShape(cornerRadius: 4.0, backgroundColor: UIColor.buttonTint)
            buttonHighPriority.tintColor = .white
            buttonNonePriority.layer.clear()
            buttonNonePriority.tintColor = .buttonTint
        case .None:
            buttonLowPriority.layer.clear()
            buttonLowPriority.tintColor = .buttonTint
            buttonMediumPriority.layer.clear()
            buttonMediumPriority.tintColor = .buttonTint
            buttonHighPriority.layer.clear()
            buttonHighPriority.tintColor = .buttonTint
            buttonNonePriority.layer.roundedShape(cornerRadius: 4.0, backgroundColor: UIColor.buttonTint)
            buttonNonePriority.tintColor = .white
        }
    }
    
    private func updateSubtaskTableLength() {
        
        // set up table height
        let cellHeight: CGFloat = self.tableSubtasks.rowHeight
        let nSubtasks: Int = self.tableSubtasks.numberOfRows(inSection: 0)
        
        var cardHeight: CGFloat = viewCard.height
        
        contraintTableViewHeight.constant = max(cellHeight * CGFloat(nSubtasks), self.view.frame.size.height - TaskNavigationViewController.TOP_MARGIN - TaskNavigationViewController.BOTTOM_MARGIN - cardHeight)
        self.viewCard.layoutIfNeeded()
        
        // set up min card height
        cardHeight = viewCard.height
        scrollView.contentSize = CGSize(width: 8.0, height: TaskNavigationViewController.TOP_MARGIN + cardHeight + TaskNavigationViewController.BOTTOM_MARGIN)
        self.view.layoutIfNeeded()
    }

    // MARK: - IBACTIONS

    // MARK: View

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var constraintCardTopMargin: NSLayoutConstraint!
    @IBOutlet weak var contraintCardHeight: NSLayoutConstraint!
    @IBOutlet weak var viewCard: UIView!
    
    @IBOutlet weak var imageDraggable: UIImageView!
    @IBOutlet weak var contraintTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var buttonLeft: UIButton! {
        didSet {
            buttonLeft.layer.borderWidth = 1.0
            buttonLeft.layer.cornerRadius = 4.0
        }
    }
    @IBAction func pressLeft(_ sender: Any) {
        // Save new Task
        if editingMode.isCreating {
            dismiss()

            //save
            dataModel.saveNewTask()
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
                self.viewCard.layoutIfNeeded()
            }
        }
        get {
            return viewDeadlinePicker.isHidden.inverse
        }
    }

    private var isDeleteButtonHidden: Bool {
        set {
            buttonDelete.isHidden = newValue
        }
        get {
            return buttonDelete.isHidden
        }
    }

    private var isDiscardButtonHidden: Bool {
        set {
            buttonDiscard.isHidden = newValue
            
            // hide the button
            if newValue == true {
                buttonDiscard.layer.borderColor = nil
                
                // show the button
            } else {
                buttonDiscard.layer.borderColor = UIColor.red.cgColor
            }
        }
        get {
            return buttonDiscard.isUserInteractionEnabled.inverse
        }
    }

    @IBOutlet weak var buttonDelete: UIButton! {
        didSet {
            buttonDelete.layer.cornerRadius = 4.0
            buttonDelete.layer.borderWidth = 1.0
            buttonDelete.layer.borderColor = UIColor.red.cgColor
        }
    }
    @IBAction func pressDeleteTask(_ sender: Any) {
        dataModel.deleteTask()
        self.dismissViewController()
    }

    @IBOutlet weak var buttonDiscard: UIButton! {
        didSet {
            buttonDiscard.layer.cornerRadius = 4.0
            buttonDiscard.layer.borderWidth = 1.0
            buttonDiscard.layer.borderColor = UIColor.red.cgColor
        }
    }
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
        task.isCompleted = buttonCheckbox.isChecked
        dataModel.saveOnlyOnReading()
    }

    var isShowingPriorityBox: Bool {
        set {
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.viewPriorityBox.isHidden = newValue.inverse
                self.viewPriorityBox.alpha = newValue ? 1.0 : 0.0
                self.viewCard.layoutIfNeeded()
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
    @IBOutlet weak var buttonLowPriority: UIButton!
    @IBOutlet weak var buttonMediumPriority: UIButton!
    @IBOutlet weak var buttonHighPriority: UIButton!
    @IBOutlet weak var buttonNonePriority: UIButton!
    @IBAction func pressA_Priority(_ sender: UIButton) {
        guard let newPriority = Task.Priorities(rawValue: sender.tag) else {
            fatalError("setting a priority to an unsupported button.tag value")
        }

        viewModel.setPriority(to: newPriority)
        
        // update prority buttons
        self.updateProrityButtons()

        //TODO: RxSwift
        imagePriorityBox.priority = newPriority
        dataModel.saveOnlyOnReading()

//        isShowingPriorityBox = false
    }

    @IBOutlet weak var buttonBreadcrum: UIButton!

    // MARK: Deadline
    @IBOutlet weak var labelDeadlineSubtext: UILabel!

    @IBOutlet weak var buttonDeadline: UIButton!
    @IBAction func pressDeadline(_ sender: Any) {
        if self.isShowingDeadlinePicker {
            self.isShowingDeadlinePicker = false
        } else {
            if task.deadline == nil {
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

    @IBOutlet weak var viewEffortValues: UIView!

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
            
            // update slider and task
            sliderEffort.value = newSliderValue
            task.duration = newSliderValue
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


    // MARK: Subtasks

    @IBOutlet weak var viewSubtasks: UIStackView!
    @IBOutlet weak var viewNonSubtasks: UIView!
    @IBOutlet weak var tableSubtasks: UITableView!
    @IBOutlet weak var textfieldAddSubtasks: UITextField!

    private var isShowingSubtasksTable: Bool {
        set {
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.viewSubtasks.isHidden = newValue.inverse
                if newValue == false {
                    self.viewSubtasks.alpha = 0.0
                } else {
                    self.viewSubtasks.alpha = 1.0
                }
                self.viewCard.layoutIfNeeded()
            }
            self.viewNonSubtasks.isHidden = newValue
        }
        get {
            return viewSubtasks.isHidden.inverse
        }
    }

    @IBAction func pressAddSubtask(_ sender: Any) {
        let alertAddTitle = UIAlertController(
            title: "Add a Subtask",
            message: "enter a title",
            preferredStyle: .alert
        )

        alertAddTitle
            .addTextField()
            .addCancelButton()
            .addButton(title: "Add") { [unowned self] (action) in
                if let newTitle = alertAddTitle.inputField.text {
                    self.dataModel.addSubtask(with: newTitle)
                }
            }
            .present(in: self)

    }
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleCell = UISubtaskTableViewCell.Types.Textfield
        tableSubtasks.register(titleCell.nib, forCellReuseIdentifier: titleCell.cellIdentifier)

        //TODO: Dynamic Font, user preferences of which cell to display
        tableSubtasks.rowHeight = 44
        
        let inputAccessory = UIInputAccessoryView.initialize(accessoryType: .Dismiss)
        inputAccessory.labelCaption.text = "hit return to add"
        inputAccessory.addActionToRightButton(action: { [unowned self] (button) in
            self.dismissKeyboardOnly()
        })
        
        textfieldAddSubtasks.inputAccessoryView = inputAccessory

        viewEffortTotal.calendarUnits = [.day, .hour, .minute]

        UIView.performWithoutAnimation { [unowned self] in
            
            // set card at the bottom and animate to the top
            self.setViewState(to: .Hidden, animated: false)
            
            //FIXME: RxSwift, rename method to viewDidLoad()
            self.updateUI()
            
            // set up min card height
            self.contraintCardHeight.constant = self.view.frame.size.height - (TaskNavigationViewController.TOP_MARGIN + TaskNavigationViewController.BOTTOM_MARGIN)
        }

        self.isShowingPriorityBox = false
        
        if editingMode.isCreating {
            self.view.bluryCard()
        }
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

        // present the keyboard on new tasks
        if editingMode.isCreating {
            textfieldTitle.becomeFirstResponder()
        }
        
        self.updateSubtaskTableLength()
    }
}

// MARK: - UITableViewDataSource
extension TaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedSubtasks.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UISubtaskTableViewCell.Types.Textfield.cellIdentifier) as! UISubtaskTableViewCell? else {
            assertionFailure("TaskTableViewCell was not registered")

            return UITableViewCell(style: .default, reuseIdentifier: "cell")
        }

        let subtask = viewModel.fetchedSubtasks.subtask(at: indexPath)
        cell.configure(subtask)
        cell.delegate = self

        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let subtask = viewModel.fetchedSubtasks.subtask(at: indexPath)
            dataModel.delete(subtask: subtask)
            dataModel.saveOnlyOnReading()
        default: break
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TaskViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableSubtasks.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableSubtasks.insertSections([sectionIndex], with: .fade)
        case .delete: tableSubtasks.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableSubtasks.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableSubtasks.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableSubtasks.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableSubtasks.deleteRows(at: [indexPath!], with: .fade)
            tableSubtasks.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableSubtasks.endUpdates()
        updateSubtaskTableLength()
    }
}

// MARK: - UISubtaskTableViewCellDelegate
extension TaskViewController: UISubtaskTableViewCellDelegate {
    func subtask(cell: UISubtaskTableViewCell, didTapCheckBox newState: Bool) {
        guard
            let indexPath = tableSubtasks.indexPath(for: cell)
            else {
            return assertionFailure("index path for cell not found")
        }

        let task = viewModel.fetchedSubtasks.subtask(at: indexPath)
        task.isCompleted = newState
        dataModel.saveOnlyOnReading()
    }

    func subtask(cell: UISubtaskTableViewCell, didChangeSubtask subtask: Subtask, to newTitle: String) {
        subtask.title = newTitle
        dataModel.saveOnlyOnReading()
    }
}

// MARK: - UITextFieldDelegate
extension TaskViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === textfieldTitle {

            textfieldTitle.resignFirstResponder() // will validate if empty
        } else if textField === textfieldAddSubtasks {
            textfieldTitle.resignFirstResponder()

            // is empty?
            if let newTitle = textfieldAddSubtasks.text, newTitle != "" {
                dataModel.addSubtask(with: newTitle)
                dataModel.saveOnlyOnReading()
                textfieldAddSubtasks.text = ""
            } else {
                textfieldAddSubtasks.resignFirstResponder()
            }
        }

        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === textfieldTitle {
            if let text = textField.text {
                task.title = text
                dataModel.saveOnlyOnReading()
            }
        }
    }

}

// MARK: - UIScrollViewDelegate
extension TaskViewController: UIScrollViewDelegate {
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

// MARK: - MoveViewControllerDelegate
extension TaskViewController: MoveViewControllerDelegate {
    func move(viewController: MoveViewController, didMove items: [Directory], to destination: Directory?) {
        //TODO: RxSwift
        buttonBreadcrum.setTitle(viewModel.parentTitle, for: .normal)
        dataModel.saveOnlyOnReading()
    }
}

// MARK: - UIStoryboardSegue

private extension UIStoryboardSegue {
    static let showMove = "show move"
}
