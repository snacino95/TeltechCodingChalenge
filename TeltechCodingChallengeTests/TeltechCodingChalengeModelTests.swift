//
//  TeltechCodingChalengeModelTests.swift
//  TeltechCodingChalengeModelTests
//
//  Created by Sergio Načivić on 15.11.2022..
//

import XCTest
@testable import TeltechCodingChalengeModel


final class TeltechCodingChalengeModelTests: XCTestCase {
  
  func testCreateCallerDetail() {
    let coreDataStack = CoreDataStack(modelString: "TeltechCodingChalengeModel", containerType: .inMemory)
    let callerDetailService = CallerDetailService(coreDataStack: coreDataStack)
    
    let phoneNumber: Int64 = 12345
    let status: CallerStatus = .blocked
    let detail = "some details"
    
    callerDetailService.createCallerDetailWith(phoneNumber: phoneNumber, status: status, details: detail)
    
    XCTAssert(coreDataStack.context.insertedObjects.count == 1)
    
    let callerDetail = coreDataStack.context.insertedObjects.first as! CallerDetail
    
    XCTAssertEqual(callerDetail.status, status, "Status does not match")
    XCTAssertEqual(callerDetail.phoneNumber, phoneNumber, "Phone number does not mach")
    XCTAssertEqual(callerDetail.details, detail, "Detail do not match")
  }
  
  
  func testDeleteAllCallerDetail() {
    let coreDataStack = CoreDataStack(modelString: "TeltechCodingChalengeModel", containerType: .inMemory)
    let callerDetailService = CallerDetailService(coreDataStack: coreDataStack)

    PrepareForTesting.setupSomeTestingDataOn(context: coreDataStack.context)
    callerDetailService.deleteCallersDetailsWhere()

    XCTAssertEqual(coreDataStack.context.deletedObjects.count, 4, "Should delete only 2 blocked numbers.")
  }

  func testFetchAllCallerDetail() {
    let coreDataStack = CoreDataStack(modelString: "TeltechCodingChalengeModel", containerType: .inMemory)
    let callerDetailService = CallerDetailService(coreDataStack: coreDataStack)

    PrepareForTesting.setupSomeTestingDataOn(context: coreDataStack.context)

    let callersDetail = callerDetailService.fetchCallersWhere(status: .blocked)
    XCTAssertEqual(callersDetail.count, 2, "There should be 2 blocked records to fetch")

    for callerDetail in callersDetail {
      XCTAssertEqual(callerDetail.status, .blocked, "Fetched caller with wrong status, should be .blocked")
    }
  }

  func testFetchSpamCallerDetail() {
    let coreDataStack = CoreDataStack(modelString: "TeltechCodingChalengeModel", containerType: .inMemory)
    let callerDetailService = CallerDetailService(coreDataStack: coreDataStack)

    PrepareForTesting.setupSomeTestingDataOn(context: coreDataStack.context)

    let callersDetail = callerDetailService.fetchCallersWhere(status: .spam)
    XCTAssertEqual(callersDetail.count, 2, "There should be 2 blocked records to fetch")

    for callerDetail in callersDetail {
      XCTAssertEqual(callerDetail.status, .spam, "Fetched caller with wrong status, should be .spam" )
    }
  }

  func testDeleteBlockedCallerDetail() {
    let coreDataStack = CoreDataStack(modelString: "TeltechCodingChalengeModel", containerType: .inMemory)
    let callerDetailService = CallerDetailService(coreDataStack: coreDataStack)

    PrepareForTesting.setupSomeTestingDataOn(context: coreDataStack.context)

    callerDetailService.deleteCallersDetailsWhere(status: .blocked)

    let deletedObject = coreDataStack.context.deletedObjects
    XCTAssertEqual(deletedObject.count, 2, "Not deleting only with status: .blocked")

    for callerDetail in deletedObject as! Set<CallerDetail> {
      XCTAssertEqual(callerDetail.status, .blocked, "Deleted record status != .blocked" )
    }
  }

  func testSaveWillNotThrow() {
    let coreDataStack = CoreDataStack(modelString: "TeltechCodingChalengeModel", containerType: .inMemory)
    let callerDetailService = CallerDetailService(coreDataStack: coreDataStack)

    PrepareForTesting.setupSomeTestingDataOn(context: coreDataStack.context)

    do {
      try callerDetailService.saveChanges()
    } catch {
      XCTAssertNil(error, "There was an error saving context")
    }
  }

  func testSaveWillThrow() {
    let coreDataStack = CoreDataStack(modelString: "TeltechCodingChalengeModel", containerType: .inMemory)
    let callerDetailService = CallerDetailService(coreDataStack: coreDataStack)

    let _ = PrepareForTesting.setupSomeTestingDataOn(context: coreDataStack.context)
    let _ = PrepareForTesting.setupSomeTestingDataOn(context: coreDataStack.context)

    do {
      try callerDetailService.saveChanges()
    } catch {
      //TODO: Test if error is CallerDetailServiceError
      XCTAssertNotNil(error)
    }
  }
}
