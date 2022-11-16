//
//  CallDirectoryHandler.swift
//  CallDirectoryExtension
//
//  Created by Sergio Načivić on 13.11.2022..
//

import Foundation
import CallKit
import TeltechCodingChalengeModel

class CallDirectoryHandler: CXCallDirectoryProvider {
  
  var callerDetailService =  CallerDetailService(coreDataStack: CoreDataStack())
  
  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
    context.delegate = self

    if let updatedAt = UserDefaults.standard.object(forKey: "updatedAt") as? Date, context.isIncremental {
    
      addOrRemoveIncrementalBlockingPhoneNumbers(to: context, since: updatedAt)
      addOrRemoveIncrementalIdentificationPhoneNumbers(to: context, since: updatedAt)
      
    } else {
      addAllBlockingPhoneNumbers(to: context)
      
      addAllIdentificationPhoneNumbers(to: context)
    }
    //LEGIT 385 99 324 9828 BEZ RAZMAKA
    context.completeRequest()
    UserDefaults.standard.set(Date(), forKey: "updatedAt")
  }
  
  private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
    // Retrieve all phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
    // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    //
    // Numbers must be provided in numerically ascending order.
  
    let allPhoneNumbers = callerDetailService.fetchCallersWhere(status: .blocked).map { $0.phoneNumber }
    
    for phoneNumber in allPhoneNumbers {
      context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
    }
  }
  
  private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext, since: Date) {
    // Retrieve any changes to the set of phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
    // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    
    let phoneNumbersToAdd = callerDetailService.fetchCallersWhere(status: .blocked, updatedAt: since, didRemove: false).map { $0.phoneNumber }
    for phoneNumber in phoneNumbersToAdd {
      context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
    }
    
    let phoneNumbersToRemove = callerDetailService.fetchCallersWhere(status: .blocked, updatedAt: since, didRemove: true).map { $0.phoneNumber }

    for phoneNumber in phoneNumbersToRemove {
      context.removeBlockingEntry(withPhoneNumber: phoneNumber)
    }
    
    // Record the most-recently loaded set of blocking entries in data store for the next incremental load...
  }
  
  private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext ) {
    // Retrieve phone numbers to identify and their identification labels from data store. For optimal performance and memory usage when there are many phone numbers,
    // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    //
    // Numbers must be provided in numerically ascending order.
    let callersDetail = callerDetailService.fetchCallersWhere(status: .spam)
    
    for callerDetail in callersDetail {
      context.addIdentificationEntry(withNextSequentialPhoneNumber: callerDetail.phoneNumber, label: callerDetail.details ?? "Not Provided")
    }
  }
  
  private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext, since: Date) {
    // Retrieve any changes to the set of phone numbers to identify (and their identification labels) from data store. For optimal performance and memory usage when there are many phone numbers,
    // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    
    let callersDetailToAdd = callerDetailService.fetchCallersWhere(status: .spam, updatedAt: since, didRemove: false)
    
    for callerDetail in callersDetailToAdd {
      context.addIdentificationEntry(withNextSequentialPhoneNumber: callerDetail.phoneNumber, label: callerDetail.details ?? "Not Provided")
    }
    
    let callersDetailToRemove = callerDetailService.fetchCallersWhere(status: .spam, updatedAt: since, didRemove: true)
    
    for callerDetail in callersDetailToRemove {
      context.removeIdentificationEntry(withPhoneNumber: callerDetail.phoneNumber)
    }
    
    // Record the most-recently loaded set of identification entries in data store for the next incremental load...
  }
  
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
  
  func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
    // An error occurred while adding blocking or identification entries, check the NSError for details.
    // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
    //
    // This may be used to store the error details in a location accessible by the extension's containing app, so that the
    // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
    // the user in Settings instead of via the app itself.
  }
  
}
