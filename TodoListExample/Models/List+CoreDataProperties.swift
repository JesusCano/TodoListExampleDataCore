//
//  List+CoreDataProperties.swift
//  TodoListExample
//
//  Created by Jesus Jaime Cano Terrazas on 04/09/21.
//
//

import Foundation
import CoreData


extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var name: String?

}

extension List : Identifiable {

}
