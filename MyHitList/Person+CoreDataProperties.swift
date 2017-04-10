//
//  Person+CoreDataProperties.swift
//  MyHitList
//
//  Created by Aleksandar Stanojcic on 4/6/17.
//  Copyright © 2017 Aleksandar Stanojcic. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person");
    }

    @NSManaged public var address: String?
    @NSManaged public var age: Int16
    @NSManaged public var eyeColor: NSObject?
    @NSManaged public var name: String
    @NSManaged public var picture: NSData?

}
