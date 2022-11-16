//
//  CallerDetail+CoreDataProperties.swift
//  TeltechCodingChallenge
//
//  Created by Sergio Načivić on 14.11.2022..
//
//

import Foundation
import CoreData


extension CallerDetail {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<CallerDetail> {
    return NSFetchRequest<CallerDetail>(entityName: "CallerDetail")
  }
  
  @NSManaged public var phoneNumber: Int64
  @NSManaged public var updatedAt: Date
  @NSManaged public var status: CallerStatus
  @NSManaged public var didRemove: Bool
  @NSManaged public var details: String?
  
}
