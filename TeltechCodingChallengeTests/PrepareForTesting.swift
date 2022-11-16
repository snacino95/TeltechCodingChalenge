//
//  PrepareForTesting.swift
//  TeltechCodingChalengeModelTests
//
//  Created by Sergio Načivić on 16.11.2022..
//

import Foundation
import CoreData

@testable import TeltechCodingChalengeModel

internal class PrepareForTesting {
  
  static func createResetCoreDataStack() -> (CoreDataStack, CallerDetailService) {
    
    let coreDataStack = CoreDataStack(modelString: "TeltechCodingChalengeModel", containerType: .inMemory)
    let callerDetailService = CallerDetailService(coreDataStack: coreDataStack)
    
    return (coreDataStack, callerDetailService)
  }
  
  static func setupSomeTestingDataOn(context: NSManagedObjectContext) {
    let blockedCallerDetail = CallerDetail(context: context)
    blockedCallerDetail.phoneNumber = 1
    blockedCallerDetail.status = .blocked
    blockedCallerDetail.details = "some details"
    blockedCallerDetail.updatedAt = Date()
    blockedCallerDetail.didRemove = true
    
    let blockedCallerDetail2 = CallerDetail(context: context)
    blockedCallerDetail2.phoneNumber = 2
    blockedCallerDetail2.status = .blocked
    blockedCallerDetail2.details = "some details"
    blockedCallerDetail2.updatedAt = Date()
    blockedCallerDetail2.didRemove = false
    
    let spamCallerDetail = CallerDetail(context: context)
    spamCallerDetail.phoneNumber = 3
    spamCallerDetail.status = .spam
    spamCallerDetail.details = "some details"
    spamCallerDetail.updatedAt = Date()
    spamCallerDetail.didRemove = false
    
    let spamCallerDetail2 = CallerDetail(context: context)
    spamCallerDetail2.phoneNumber = 4
    spamCallerDetail2.status = .spam
    spamCallerDetail2.details = "some details"
    spamCallerDetail2.updatedAt = Date()
    spamCallerDetail2.didRemove = false
    
    
    do {
      try context.save()
    } catch {
      
    }
  }
}
