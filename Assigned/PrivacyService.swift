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
        
        static var isAuthorized: Bool {
            let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
            
            switch (status) {
            case EKAuthorizationStatus.authorized:
                return true
            case EKAuthorizationStatus.notDetermined, EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
                return false
            }
        }
        
        private static var successfulHandler: (() -> ())?
        private static var failureHandler: (() -> ())?
        
        /**
         checks the system if this app is currently authorized to access calendars
         
         - postcondition: updates the stored var
         */
        static func authorize(successfulHandler: (() -> ())? = nil, failureHandler: (() -> ())? = nil) {
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
                successfulHandler?()
            case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
                
                // We need to help them give us permission
                failureHandler?()
            }
        }
        
        private static func requestAuthorization() {
            let eventStore = EKEventStore()
            
            //TODO: revise Info.plist - Privacy – Calendars Usage Description
            eventStore.requestAccess(to: EKEntityType.event, completion: {
                (accessGranted: Bool, error: Error?) in
                
                // User presses yes
                if accessGranted == true {
                    DispatchQueue.main.async(execute: {
                        self.successfulHandler?()
                    })
                    
                // User presses no
                } else {
                    DispatchQueue.main.async(execute: {
                        self.failureHandler?()
                    })
                }
            })
        }
    }
}
