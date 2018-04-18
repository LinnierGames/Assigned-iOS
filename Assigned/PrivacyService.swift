//
//  PrivacyService.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import EventKit

// Provides a default uialertcontroller to promot the user a message
import UIKit

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
            // illstrate that sessions created in-app will reflect the user's
            //ical, adding, updating, and deleting events
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
        
        /**
         <#Lorem ipsum dolor sit amet.#>
         
         - parameter openedLinkCompleition: Provide a value for this parameter if you want to be informed of the success or failure of opening the URL. This block is executed asynchronously on your app's main thread.
         
         - returns: <#Sed do eiusmod tempor.#>
         */
        static func promptAlert(in viewController: UIViewController, with alertStyle: UIAlertControllerStyle, openedLinkCompleition: ((Bool) -> ())? = nil) {
            
            //TODO: localized string
            UIAlertController(title: "Access to iCal", message: "Assigned needs to have access to your calendar. Please open the Settings app and enable Calendar", preferredStyle: alertStyle)
                .addConfirmationButton(title: "Open Settings", with: { (action) in
                    
                    // url to open settings
                    UIApplication.shared.openAppSettings(completion: openedLinkCompleition)
                })
                .present(in: viewController)
        }
    }
}
