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
    
    /** assigned by the parent view controller */
    var panGesture: UIPanGestureRecognizer!
    
    lazy private(set) var viewModel = TaskPanelViewModel(delegate: self)
    
    var fetchedResultsController: NSFetchedResultsController<Assignment>? {
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
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func reloadData() {
        self.viewModel.reloadTasks()
        self.updateUI()
    }
    
    private func updateUI() {
        collectionView.reloadData()
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var collectionView: UIBatchableCollectView!
    @IBOutlet weak var viewHitbox: UIView!
    @IBOutlet weak var segmentFilter: UISegmentedControl!
    @IBAction func didChangeFilter(_ sender: Any) {
        guard let newFilter = TaskPanelViewModel.SearchFilter(rawValue: segmentFilter.selectedSegmentIndex) else {
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
        
        let task = self.fetchedResultsController!.assignment(at: indexPath)
        cell.configure(task)
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
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
