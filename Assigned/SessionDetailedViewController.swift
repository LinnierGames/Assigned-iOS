//
//  SessionViewController.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/20/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class SessionDetailedViewController: UIViewController {
    
    var viewModel = SessionDetailedViewModel()
    
    public var session: Session {
        set {
            viewModel.session = newValue
        }
        get {
            return viewModel.session
        }
    }

    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE

}
