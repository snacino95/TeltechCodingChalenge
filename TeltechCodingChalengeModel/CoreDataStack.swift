//
//  CoreDataStack.swift
//  CoreDataStack
//
//  Created by Sergio Načivić on 13.11.2022..
//

import Foundation
import CoreData

public class CoreDataStack {
  
  private var modelString: String
  private var containerType: NSPersistentStore.StoreType
  
  public init(modelString: String = "TeltechCodingChalengeModel", containerType: NSPersistentStore.StoreType = .sqlite ) {
    self.modelString = modelString
    self.containerType = containerType
  }
  
  
  private lazy var persistentContainer: NSPersistentContainer = {
    let momdName = modelString
    let groupName = "group.com.Sergio"
    let fileName = "demo.sqlite"
    
    guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension:"momd") else {
      fatalError("Error loading model from bundle")
    }
    
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Error initializing mom from: \(modelURL)")
    }
    
    guard let baseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName) else {
      fatalError("Error creating base URL for \(groupName)")
    }
    
    let storeUrl = baseURL.appendingPathComponent(fileName)
    
    let container = NSPersistentContainer(name: momdName, managedObjectModel: mom)
    
    let description = NSPersistentStoreDescription()
    
    description.url = storeUrl
    description.type = containerType.rawValue
    
    container.persistentStoreDescriptions = [description]
    
    container.loadPersistentStores {
      (storeDescription, error) in
      if let error = error as NSError? {
        print("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  public var context: NSManagedObjectContext { return self.persistentContainer.viewContext }
}

