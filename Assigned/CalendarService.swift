//
//  CalendarService.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/7/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import CoreData
import EventKit

class CalendarService {
    
    static var shared = CalendarService()
    
    init() {
        
        // EKEventStoreChanged
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CalendarService.eventStoreDidChange(_:)),
            name: NSNotification.Name.EKEventStoreChanged,
            object: nil
        )
        
        // UIApplicationDidBecomeActive
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CalendarService.applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    }
    
    deinit {
        
        // Unsubscribe from all stations
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    @objc private func applicationDidBecomeActive( _ notification: Notification) {
        if PrivacyService.Calendar.isAuthorized {
            self.updateStaleSession()
        }
    }
    
    @objc private func eventStoreDidChange( _ notification: Notification) {
        if PrivacyService.Calendar.isAuthorized {
            self.updateStaleSession()
        } else {
            debugPrint("PrivacyService.Calendar.isAuthorized == false for eventStoreDidChange(notification:)")
        }
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - precondition: check for privacy before calling this method
     */
    private func updateStaleSession() {
        let persistanceStore = PersistenceStack.shared
        let privateContext = persistanceStore.newBackgroundContext()
        
        do {
            let fetch: NSFetchRequest<Session> = Session.fetchRequest()
            let sessions = try privateContext.fetch(fetch)
            
            // Update stale sessions
            let calendar = try! CalendarStack()
            sessions.forEach({ (aSession) in
                if let sessionEvent = calendar.event(for: aSession) {
                    aSession.setValuesIfNeededFor(event: sessionEvent)
                    
                // delete session
                } else {
                    privateContext.delete(aSession)
                }
            })
            
            let modifiedObjects = privateContext.updatedObjects.union(privateContext.deletedObjects) as! Set<Session>
            
            // Save and notify observers of new changes
            persistanceStore.saveContext(context: privateContext)
            NotificationCenter.default.post(name: Notification.Name.CalendarServiceDidUpdateStaleSessions, object: modifiedObjects)
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}

extension Notification.Name {
    static let CalendarServiceDidUpdateStaleSessions = Notification.Name("updatedStaleSessions")
}
