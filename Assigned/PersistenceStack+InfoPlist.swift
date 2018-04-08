//
//  PersistenceStack+InfoPlist.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/8/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation

extension PersistenceStack {
    
    enum AAInfoErrors: Error {
        case NoInfoPistFound
        case KeyNotFound
        
    }
    
    func buildShortVersion() throws -> String {
        guard let info = Bundle.main.infoDictionary else {
            throw AAInfoErrors.NoInfoPistFound
        }
        
        guard let keyValue = info["CFBundleShortVersionString"] as! String? else {
            throw AAInfoErrors.KeyNotFound
        }
        
        return keyValue
    }
    
    func gitCommitSHA1() throws -> String {
        guard let info = Bundle.main.infoDictionary else {
            throw AAInfoErrors.NoInfoPistFound
        }
        
        guard let keyValue = info["CFBundleVersion"] as! String? else {
            throw AAInfoErrors.KeyNotFound
        }
        
        return keyValue
    }
    
    func buildTime() throws -> String {
        guard let info = Bundle.main.infoDictionary else {
            throw AAInfoErrors.NoInfoPistFound
        }
        
        guard let keyValue = info["BuildTime"] as! String? else {
            throw AAInfoErrors.KeyNotFound
        }
        
        return keyValue
    }
    
    func gitCommitDebugMessage() -> String {
        do {
            let shortVersion = try self.buildShortVersion()
            let gitSHA1 = try self.gitCommitSHA1()
            let buildTime = try self.buildTime()
            
            return "\(shortVersion) - \(gitSHA1) @ \(buildTime)"
            
        } catch let err {
            fatalError(err.localizedDescription)
        }
    }
}
