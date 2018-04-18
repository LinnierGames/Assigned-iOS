//
//  UIBatchableCollectView.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/3/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class UIBatchableCollectView: UICollectionView {
    
    typealias Batch = (UIBatchableCollectView) -> ()
    
    private(set) var unperformedBatch: [Batch] = []

    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    func beginUpdates() {
        unperformedBatch.removeAll()
    }
    
    func addBatch(_ batch: @escaping Batch) {
        unperformedBatch.append(batch)
    }
    
    func endUpdates(completion: ((Bool) -> ())? = nil) {
        performBatchUpdates({ [unowned self] in
            for aBatch in self.unperformedBatch {
                aBatch(self)
            }
        }, completion: completion)
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE

}
