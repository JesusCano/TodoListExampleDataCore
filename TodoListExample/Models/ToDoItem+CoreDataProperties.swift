//
//  ToDoItem+CoreDataProperties.swift
//  TodoListExample
//
//  Created by Jesus Jaime Cano Terrazas on 04/09/21.
//
//

import Foundation
import CoreData


extension ToDoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoItem> {
        return NSFetchRequest<ToDoItem>(entityName: "ToDoItem")
    }

    @NSManaged public var title: String?
    @NSManaged public var notes: String?
    @NSManaged public var done: Bool
    @NSManaged public var color: NSObject?

}

extension ToDoItem : Identifiable {

}
