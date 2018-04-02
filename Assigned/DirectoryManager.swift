//
//  DirectoryManager.swift
//  Assigned
//
//  Created by Erick Sanchez on 4/2/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation

struct DirectoryManager {
    
    // MARK: Update Parent
    
    func move(directory: Directory, to destination: Directory?) {
        move(directories: [directory], to: destination)
    }
    
    func move(directories: [Directory], to destination: Directory?) {
        for aDirectoryToMove in directories {
            aDirectoryToMove.parent = destination
        }
    }
    
    // MARK: Making Copies
    
    @discardableResult
    func duplicate(directory: Directory, to destination: Directory?) -> Directory {
        return duplicate(directories: [directory], to: destination).first!
    }
    
    //TODO: perhaps use a set vs an array
    @discardableResult
    func duplicate(directories: [Directory], to destination: Directory?) -> [Directory] {
        var newDirectories = [Directory]()
        for aDirectoryToCopy in directories {
            let newDirectory = Directory(copy: aDirectoryToCopy)
            newDirectories.append(newDirectory)
        }
        
        return newDirectories
    }
}
