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
    
    var fetchedResultsController: NSFetchedResultsController<Assignment>! {
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
    
    lazy var viewModel = TaskPanelViewModel(delegate: self)

    enum SearchFilter: Int {
        case SelectedDay = 0
        case Priority
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
        
        let fetch: NSFetchRequest<Assignment> = Assignment.fetchRequest()
        switch selectedFilter {
        case .SelectedDay:
            fetch.predicate = NSPredicate(date: Date(), for: "deadline")
            fetch.sortDescriptors = [NSSortDescriptor(key: Assignment.StringKeys.deadline, ascending: true)]
        case .Priority:
            fetch.predicate = nil
            fetch.sortDescriptors = [NSSortDescriptor(key: Assignment.StringKeys.priorityValue, ascending: true)]
        case .AllTasks:
            fetch.predicate = nil
            fetch.sortDescriptors = [NSSortDescriptor(key: Assignment.StringKeys.deadline, ascending: true)]
        case .None:
            fetch.sortDescriptors = [NSSortDescriptor(key: Assignment.StringKeys.deadline, ascending: true)]
        }
        
        self.fetchedResultsController = NSFetchedResultsController<Assignment>(
            fetchRequest: fetch,
            managedObjectContext: self.viewModel.context,
            sectionNameKeyPath: nil, cacheName: nil
        )
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var collectionView: UIBatchableCollectView!
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
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UITaskCollectionViewCell.Types.baseCell.cellIdentifier, for: indexPath) as! UITaskCollectionViewCell
        
        let task = self.fetchedResultsController.assignment(at: indexPath)
        cell.labelTitle.text = task.title
        if let deadline = task.deadline {
            cell.labelSubtitle.text = String(date: deadline, dateStyle: .short, timeStyle: .short)
        } else {
            cell.labelSubtitle.text = nil
        }
        
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
