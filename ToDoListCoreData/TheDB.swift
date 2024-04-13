//
//  TheDB.swift
//  ToDoListCoreData
//
//  Created by Marwan Al.Jabri on 04/10/1445 AH.
//

import CoreData

struct TheDB {
    
    static let shared = TheDB()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoreData")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(filePath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            print("Error while loading CoreData")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        
    }
    
}
