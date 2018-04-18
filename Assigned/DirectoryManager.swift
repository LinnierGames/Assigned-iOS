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
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - warning: <#Consectetur adipisicing elit.#>
     */
    func move(directory: Directory, to destination: Directory?) {
        move(directories: [directory], to: destination)
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - warning: <#Consectetur adipisicing elit.#>
     */
    func move(directories: [Directory], to destination: Directory?) {
        for aDirectoryToMove in directories {
            aDirectoryToMove.parent = destination
        }
    }
    
    // MARK: Making Copies
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - warning: <#Consectetur adipisicing elit.#>
     */
    @discardableResult
    func duplicate(directory: Directory, to destination: Directory?) -> Directory {
        return duplicate(directories: [directory], to: destination).first!
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - warning: <#Consectetur adipisicing elit.#>
     */
    //TODO: perhaps use a set vs an array
    @discardableResult
    func duplicate(directories: [Directory], to destination: Directory?) -> [Directory] {
        var newDirectories = [Directory]()
        for aDirectoryToCopy in directories {
            let newDirectory = aDirectoryToCopy.copying()
            newDirectories.append(newDirectory)
        }
        
        return newDirectories
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - warning: <#Consectetur adipisicing elit.#>
     */
    func delete(directory: Directory) {
        delete(directories: [directory])
    }
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - warning: <#Consectetur adipisicing elit.#>
     */
    func delete(directories: [Directory]) {
        
        let persistence = PersistenceStack.shared
        
        for aDirectory in directories {
            persistence.viewContext.delete(aDirectory)
        }
    }
}
