//
//  DataController.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 14/04/2022.
//

import Foundation

import Foundation
import CoreData

class DataController {
    let persitentContainer: NSPersistentContainer
    
    var viewContex: NSManagedObjectContext {
        return persitentContainer.viewContext
    }
    
    var backgroundContext:NSManagedObjectContext!
    
    init(modelName: String){
      persitentContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContext(){
        backgroundContext = persitentContainer.newBackgroundContext()
        viewContex.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContex.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil){
        persitentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureContext()
            completion?()
        }
    }
}
