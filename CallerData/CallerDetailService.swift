//
//  CoreDataService.swift
//  TeltechCodingChallenge
//
//  Created by Sergio Načivić on 13.11.2022..
//

import Foundation
import CoreData

public enum CallerDetailServiceError: Error {
  case duplicateEntry(String)
  case unknown
}

public class CallerDetailService {
  
  private let coreDataStack: CoreDataStack!
  private var context: NSManagedObjectContext {
    get {
      return coreDataStack.context
    }
  }
  
  public init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
    self.coreDataStack = coreDataStack
  }
  
  public func fetchCallersWith(status: CallerStatus? = nil, andUpdatedAt: Date? = nil, andDidRemove: Bool? = nil) -> [CallerDetail] {
    let fetchRequest = CallerDetail.fetchRequest()
    
    var subPredicates: [NSPredicate] = []
    
    if let safeStatus = status {
      let predicate = NSPredicate(format: "status = %d", safeStatus.rawValue)
      subPredicates.append(predicate)
    }
    
    if let safeUpdatedAt = andUpdatedAt {
      let predicate = NSPredicate(format: "updatedAt > %@", safeUpdatedAt as NSDate)
      subPredicates.append(predicate)
    }
    
    if let safeDidRemove = andDidRemove {
      let predicate = NSPredicate(format: "didRemove = %d", safeDidRemove)
      subPredicates.append(predicate)
    }
    
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "phoneNumber", ascending: true)]
    
    if !subPredicates.isEmpty {
      fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)
    }
    
    //TODO: Rework this
    do {
      return try context.fetch(fetchRequest)
    } catch {
      return []
    }
  }
  
  public func createCallerDetailWith(phoneNumber: Int64, status: CallerStatus, details: String? = nil ) {

    let callerDetail =  CallerDetail(context: context)
    callerDetail.phoneNumber = phoneNumber
    
    callerDetail.status = status
    callerDetail.details = details
    callerDetail.updatedAt = Date()
  }
  
  public func saveChanges() throws {
    do {
      try context.save()
    } catch {
      try handle(error: error)
    }
  }
  
  public func deleteCallersDetailsWhere(status: CallerStatus? = nil, andUpdatedAt: Date? = nil, andDidRemove: Bool? = nil) {
    
    let callersDetail = fetchCallersWith(status: status, andUpdatedAt: andUpdatedAt, andDidRemove: andDidRemove)
    
    for callerDetail in callersDetail {
      context.delete(callerDetail)
    }
  }
  
  func handle(error: Error) throws {
    switch (error as NSError).code {
    case NSManagedObjectConstraintMergeError:
      context.rollback()
      throw CallerDetailServiceError.duplicateEntry("Seems like number already exists")
    default:
      throw CallerDetailServiceError.unknown
    }
  }
}

