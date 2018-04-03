//
//  PlanViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/3/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class PlanViewController: UIViewController {
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "embed task panel":
                guard let vc = segue.destination as? TaskPanelViewController else {
                    fatalError("TaskPanelViewController was not set correctly in the storyboard")
                }
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PlanViewController.didPanTaskPanel(_:)))
                vc.view.addGestureRecognizer(panGesture)
            default: break
            }
        }
    }
    
    @objc private func didPanTaskPanel(_ sender: Any) {
        print("AAAAAA")
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonFinish: UIButton!
    @IBAction func pressFinish(_ sender: Any) {
        self.presentingViewController!.dismiss(animated: true)
    }
    
    // MARK: - LIFE CYCLE
    

}
