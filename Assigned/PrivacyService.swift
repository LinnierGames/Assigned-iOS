//
//  PrivacyService.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import EventKit

struct PrivacyService {
    
    // MARK: - Calendar
    
    struct Calendar {
        
        private static var successfulHandler: (() -> ())?
        private static var failureHandler: (() -> ())?
        
        static func authorize(successfulHandler: @escaping () -> (), failureHandler: @escaping () -> ()) {
            self.successfulHandler = successfulHandler
            self.failureHandler = failureHandler
            
            self.checkIfAuthorized()
        }
        
        private static func checkIfAuthorized() {
            
            let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
            
            switch (status) {
            case EKAuthorizationStatus.notDetermined:
                self.requestAuthorization()
                
            case EKAuthorizationStatus.authorized:
                
                // Things are in line with being able to show the calendars in the table view
                successfulHandler!()
            case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
                
                // We need to help them give us permission
                failureHandler!()
            }
        }
        
        private static func requestAuthorization() {
            let eventStore = EKEventStore()
            
            //TODO: revise Info.plist - Privacy – Calendars Usage Description
            eventStore.requestAccess(to: EKEntityType.event, completion: {
                (accessGranted: Bool, error: Error?) in
                
                if accessGranted == true {
                    DispatchQueue.main.async(execute: {
                        self.successfulHandler!()
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        self.failureHandler!()
                    })
                }
            })
        }
    }
}
