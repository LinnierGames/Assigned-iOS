//
//  TaskPanelViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/3/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import CoreData

class TaskPanelViewController: UIViewController {
    
    var planViewController: PlanViewController {
        get {
            guard
                let viewController = self.parent,
                let planViewController = viewController as? PlanViewController else {
                    fatalError("parent view controller is not PlanViewController")
            }
            
            return planViewController
        }
    }
    
    //TODO: use a delegate to subsittute the target action selector
    /** assigned by the parent view controller */
    var panGesture: UIPanGestureRecognizer!
    
    private(set) lazy var viewModel = TaskPanelViewModel(delegate: self)
    
    var fetchedResultsController: NSFetchedResultsController<Task>? {
        get {
            return viewModel.fetchedTasks
        }
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - warning: if selected filter is set to day, updating this value will reload
     the table
     */
    var selectedDay: Date {
        set {
            viewModel.selectedDate = newValue
            if self.selectedFilter == .SelectedDay {
                self.reloadData()
            }
        }
        get {
            return viewModel.selectedDate
        }
    }
    
    var selectedFilter: TaskPanelViewModel.SearchFilter {
        set {
            viewModel.selectedFilter = newValue
            
            segmentFilter.selectedSegmentIndex = newValue.rawValue
            reloadData()
        }
        get {
            return viewModel.selectedFilter
        }
    }
    
    var isShowingCompletedTasks: Bool {
        set {
            viewModel.isShowingCompletedTasks = newValue
            reloadData()
        }
        get {
            return viewModel.isShowingCompletedTasks
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func setDisplayToExpanded() {
        UIView.animate(withDuration: TimeInterval.transitionAnimationDuration) { [unowned self] in
            self.buttonEdit.alpha = 1.0
            self.labelInstruction.alpha = 1.0
            self.labelHeadline.alpha = 1.0
            self.labelBody.alpha = 1.0
        }
    }
    
    func setDisplayToMinizied() {
        UIView.animate(withDuration: TimeInterval.transitionAnimationDuration) { [unowned self] in
            self.buttonEdit.alpha = 1.0
            self.labelInstruction.alpha = 1.0
            self.labelHeadline.alpha = 1.0
            self.labelBody.alpha = 1.0
        }
    }
    
    func setDisplayToHidden() {
        UIView.animate(withDuration: TimeInterval.transitionAnimationDuration) { [unowned self] in
            self.buttonEdit.alpha = 0.0
            self.labelInstruction.alpha = 0.0
            self.labelHeadline.alpha = 0.0
            self.labelBody.alpha = 0.0
        }
    }
    
    func reloadData() {
        self.viewModel.reloadTasks()
        self.updateUI()
    }
    
    private func updateUI() {
        
        // showing completed tasks
        let showingCompletedTaskTitle = self.isShowingCompletedTasks ? "Show Uncompleted Tasks" : "Show Completed Tasks"
        self.buttonShowCompletedTasks.tintColor = self.isShowingCompletedTasks ? .white : .buttonTint
        self.buttonShowCompletedTasks.setTitle(showingCompletedTaskTitle, for: .normal)
        UIView.animate(withDuration: TimeInterval.transitionAnimationDuration) { [unowned self] in
            if self.isShowingCompletedTasks {
                self.buttonShowCompletedTasks.layer.backgroundColor = UIColor.buttonTint.cgColor
            } else {
                self.buttonShowCompletedTasks.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
        
        self.updateLabels()
        
        self.tableView.reloadData()
    }
    
    private func updateLabels() {
        
        // instruction
        let nTasks = tableView(self.tableView, numberOfRowsInSection: 0)
        if nTasks == 0 {
            self.labelInstruction.text = ""
        } else {
            self.labelInstruction.text = "Tap and hold to add to calendar"
        }
        
        // Headline and body
        if self.viewModel.userHasCreatedFirstTask {
            let nTasks = tableView(self.tableView, numberOfRowsInSection: 0)
            if nTasks == 0 {
                
                //TODO: display random headlines and bodies
                self.labelHeadline.text = "No tasks here"
                switch selectedFilter {
                case .Urgency:
                    self.labelBody.text = "There are no tasks in need of planning. Good stuff!"
                case .SelectedDay:
                    let selectedDateText: String
                    if selectedDay.isSameDay(as: Date()) {
                        selectedDateText = "today"
                    } else {
                        selectedDateText = String(date: self.selectedDay, formatterMap: .Day_ofTheWeekInTheMonth, ", ", .Month_shorthand, " ", .Day_ofTheMonthSingleDigit)
                    }
                    self.labelBody.text = "There are no tasks due for \(selectedDateText)!"
                case .AllTasks:
                    self.labelBody.text = "Nice job! You have no tasks to complete"
                }
            } else {
                self.labelHeadline.text = nil
                self.labelBody.text = nil
            }
            self.labelInstruction.isHidden = false
        } else {
            self.labelHeadline.text = "No tasks, yet 😏"
            self.labelBody.text = "Let's braindump some ideas! Press + to get started"
            self.labelInstruction.isHidden = true
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.tableView.setEditing(editing, animated: animated)
        
        if editing {
            self.buttonEdit.setTitle("Done", for: .normal)
        } else {
            self.buttonEdit.setTitle("Edit", for: .normal)
        }
    }
    
    // MARK: - IBACTIONS
    
//    @IBOutlet weak var collectionView: UIBatchableCollectView!
    @IBOutlet weak var viewHitbox: UIView!
    
    @IBOutlet weak var buttonAddTask: UIButton!
    @IBAction func pressAddTask(_ sender: Any) {
        self.performSegue(withIdentifier: UIStoryboardSegue.showTask, sender: nil)
    }
    
    @IBOutlet weak var buttonEdit: UIButton!
    @IBAction func pressEdit(_ sender: Any) {
        self.setEditing(self.tableView.isEditing.inverse, animated: true)
    }
    
    @IBOutlet weak var labelInstruction: UILabel!
    @IBOutlet weak var labelHeadline: UILabel!
    @IBOutlet weak var labelBody: UILabel!
    
    @IBOutlet weak var segmentFilter: UISegmentedControl!
    @IBAction func didChangeFilter(_ sender: Any) {
        guard let newFilter = TaskPanelViewModel.SearchFilter(rawValue: segmentFilter.selectedSegmentIndex) else {
            fatalError("segment for undefined enum case")
        }
        
        selectedFilter = newFilter
        self.updateLabels()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonShowCompletedTasks: UIButton!
    @IBAction func pressShowCompletedTasks(_ sender: Any) {
        self.isShowingCompletedTasks.invert()
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cell = UIDraggableTaskTableViewCell.Types.baseCell
        tableView.register(cell.nib, forCellReuseIdentifier: cell.cellIdentifier)
        
        self.view.addGestureRecognizer(self.panGesture)
        
        self.tableView.alwaysBounceVertical = false
        
        self.buttonEdit.layer.roundedOutline()
        self.buttonShowCompletedTasks.layer.roundedOutline()
    }

}

// MARK: - UITableViewDataSource, UITabBarDelegate

extension TaskPanelViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: RETURN VALUES
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIDraggableTaskTableViewCell.Types.baseCell.cellIdentifier) as! UIDraggableTaskTableViewCell
        
        let task = self.fetchedResultsController!.task(at: indexPath)
        cell.configure(task)
        
        cell.gestureDelegate = self.planViewController
        cell.longTapGestureDelegate = self.planViewController
        cell.delegate = self
        
        return cell
    }
    
    // MARK: VOID METHODS
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case UIStoryboardSegue.showTask:
                guard let navVc = segue.destination as? TaskNavigationViewController else {
                    fatalError("segue did not have a destination of TaskNavigationViewController")
                }
                
                // modifying an exsiting task or adding a new one?
                if let indexPath = sender as? IndexPath {
                    let selectedTask = self.viewModel.fetchedTasks!.task(at: indexPath)
                    navVc.task = selectedTask
                    navVc.editingMode = .Read
                    
                    // adding a new task
                } else {
                    navVc.editingMode = .Create
                    navVc.taskParentDirectory = nil //always is nil since there are no directories (mvp)
                }
            default: break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.viewModel.deleteTask(at: indexPath)
        self.viewModel.save()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: UIStoryboardSegue.showTask, sender: indexPath)
    }
    
    // MARK: IBACTIONS
    
    // MARK: LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
    }
}

extension TaskPanelViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        self.planViewController.setTaskPanel(to: .Hidden)
        
        return true
    }
}

// MARK: - UIDraggableTaskTableViewCellDelegate

extension TaskPanelViewController: UIDraggableTaskTableViewCellDelegate {
    
    
    func task(cell: UIDraggableTaskTableViewCell, didPress checkbox: UIButton, with newState: Bool) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return assertionFailure("index path not found for cell")
        }

        let task = self.viewModel.fetchedTasks!.task(at: indexPath)
        task.isCompleted = newState
        self.viewModel.save()
    }
}

// MARK: - TaskPanelViewModel.TaskPanelViewModelDelegate & NSFetchedResultsControllerDelegate
extension TaskPanelViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        self.updateLabels()
    }
}

// MARK: - UIStoryboardSegue

fileprivate extension UIStoryboardSegue {
    static let showTask = "show task"
}
