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
    
    var viewModel = TaskPanelViewModel(delegate: self)

    enum SearchFilter: Int {
        case SelectedDay = 0
        case AllTasks
        case None
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
        
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var collectionView: UICollectionView!
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
    }

}

extension TaskPanelViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - RETURN VALUES
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UITaskCollectionViewCell.Types.baseCell.cellIdentifier, for: indexPath) as! UITaskCollectionViewCell
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}

// MARK: - TaskPanelViewModel.TaskPanelViewModelDelegate & NSFetchedResultsControllerDelegate
extension TaskPanelViewController: TaskPanelViewModel.TaskPanelViewModelDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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
    }
}
