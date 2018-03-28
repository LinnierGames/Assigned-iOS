//
//  AssignmentSessionViewModel.swift
//  Assigned
//
//  Created by Erick Sanchez on 3/27/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation

class SessionViewModel {
    
    lazy var assignment: Assignment = Assignment.createAssignment(title: "", effort: 0, in: self.context)
    
    var context = PersistenceStack.shared.viewContext.newChildContext()
    
}

extension SessionViewModel {
    func addSession(date: Date = Date()) -> Session {
        //TODO: remove assignement.title as an optional
        let sessionTitle = assignment.title ?? "Untitled Assignment"
        
        let newSession = Session(
            name: sessionTitle,
            date: date,
            duration: 1,
            assignment: assignment, in: context)
        
        return newSession
    }
}
