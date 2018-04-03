//
//  RootTabBarController.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/3/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController, UITabBarControllerDelegate {

    // MARK: - RETURN VALUES
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if
            viewController is AgendaViewController == true ||
            (viewController is UINavigationController == true && (viewController as! UINavigationController).topViewController! is OrganizeTableViewController == true) {
                return true
        }
        
        // Present PlanViewController
        self.performSegue(withIdentifier: "show plan", sender: nil)
        
        return false
    }
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.delegate = self
    }

}
