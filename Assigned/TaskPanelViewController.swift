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
    
    var panGesture: UIPanGestureRecognizer!
    
    lazy private(set) var viewModel = TaskPanelViewModel(delegate: self)

    enum SearchFilter: Int {
        case SelectedDay = 0
        case Priority
        case AllTasks
        case None
    }
    
    private(set) var fetchedResultsController: NSFetchedResultsController<Assignment>! {
        didSet {
            if let controller = fetchedResultsController {
                controller.delegate = self
                do {
                    try controller.performFetch()
                } catch {
                    print(error.localizedDescription)
                }
            }
            collectionView.reloadData()
        }
    }
    
    var selectedDay: Date = Date() {
        didSet {
            if self.selectedFilter == .SelectedDay {
                self.updateUI()
            }
        }
    }
    
    var selectedFilter = SearchFilter.SelectedDay {
        willSet {
            segmentFilter.selectedSegmentIndex = newValue.rawValue
        }
        didSet {
            updateUI()
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        
        let fetch: NSFetchRequest<Assignment> = Assignment.fetchRequest()
        
        let sortDeadline = NSSortDescriptor(key: Assignment.StringKeys.deadline, ascending: false)
        let sortPriority = NSSortDescriptor(key: Assignment.StringKeys.priorityValue, ascending: false)
        let sortTitle = NSSortDescriptor.localizedStandardCompare(with: Assignment.StringKeys.title, ascending: false)
        switch selectedFilter {
        case .SelectedDay:
            fetch.predicate = NSPredicate(date: self.selectedDay, for: "deadline")
            fetch.sortDescriptors = [
                sortDeadline,
                sortPriority,
                sortTitle
            ]
        case .Priority:
            fetch.predicate = nil
            fetch.sortDescriptors = [
                sortPriority,
                sortDeadline,
                sortTitle
            ]
        case .AllTasks:
            fetch.predicate = nil
            fetch.sortDescriptors = [
                sortDeadline,
                sortPriority,
                sortTitle
            ]
        case .None:
            fetch.sortDescriptors = [
                sortDeadline
            ]
        }
        
        self.fetchedResultsController = NSFetchedResultsController<Assignment>(
            fetchRequest: fetch,
            managedObjectContext: self.viewModel.context,
            sectionNameKeyPath: nil, cacheName: nil
        )
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var collectionView: UIBatchableCollectView!
    @IBOutlet weak var viewHitbox: UIView!
    @IBOutlet weak var segmentFilter: UISegmentedControl!
    @IBAction func didChangeFilter(_ sender: Any) {
        guard let newFilter = SearchFilter(rawValue: segmentFilter.selectedSegmentIndex) else {
            fatalError("segment for undefined enum case")
        }
        
        selectedFilter = newFilter
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cell = UITaskCollectionViewCell.Types.baseCell
        collectionView.register(cell.nib, forCellWithReuseIdentifier: cell.cellIdentifier)
        
        viewHitbox.addGestureRecognizer(self.panGesture)
    }

}

extension TaskPanelViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - RETURN VALUES
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UITaskCollectionViewCell.Types.baseCell.cellIdentifier, for: indexPath) as! UITaskCollectionViewCell
        
        let task = self.fetchedResultsController.assignment(at: indexPath)
        cell.configure(task)
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
    }
}

// MARK: - TaskPanelViewModel.TaskPanelViewModelDelegate & NSFetchedResultsControllerDelegate
extension TaskPanelViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        collectionView.addBatch { (collectionView) in
            switch type {
            case .insert: collectionView.insertSections([sectionIndex])
            case .delete: collectionView.deleteSections([sectionIndex])
            default: break
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        collectionView.addBatch { (collectionView) in
            switch type {
            case .insert:
                collectionView.insertItems(at: [newIndexPath!])
            case .delete:
                collectionView.deleteItems(at: [indexPath!])
            case .update:
                collectionView.reloadItems(at: [indexPath!])
            case .move:
                collectionView.deleteItems(at: [indexPath!])
                collectionView.insertItems(at: [newIndexPath!])
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.endUpdates()
    }
}
