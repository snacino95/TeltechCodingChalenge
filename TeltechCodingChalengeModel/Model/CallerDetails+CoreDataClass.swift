//
//  CallerDetail+CoreDataClass.swift
//  TeltechCodingChallenge
//
//  Created by Sergio Načivić on 14.11.2022..
//
//

import Foundation
import CoreData

@objc public enum CallerStatus: Int16 {
  case blocked = 0
  case spam = 1
}


@objc(CallerDetail)
public class CallerDetail: NSManagedObject {
  
}
