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
    
    private var touchOffset: CGFloat?
    @objc private func didPanTaskPanel(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let location = gesture.location(in: self.view)
            touchOffset = location.y - viewTaskPanel.frame.origin.y
        case .changed:
            guard let touchOffset = self.touchOffset else {
                return assertionFailure("No touch offset was made in the .began state of this gesture")
            }
            let newPoint = gesture.location(in: self.view)
            viewTaskPanel.frame.origin.y = newPoint.y - touchOffset
        case .ended:
            break
        default:
            break
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonFinish: UIButton!
    @IBAction func pressFinish(_ sender: Any) {
        self.presentingViewController!.dismiss(animated: true)
    }
    
    @IBOutlet weak var viewTaskPanel: UIView!
    
    // MARK: - LIFE CYCLE
    

}
