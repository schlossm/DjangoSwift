//
//  Extensions.swift
//  RESTSwift
//
//  Created by Michael Schloss on 11/23/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation
import CoreData

public extension String
{
    var urlEncoded : String
    {
        let resultBytes = utf8.flatMap { $0.urlEncodedBytes }
        return String(bytes: resultBytes, encoding: .utf8) ?? self
    }
}

public extension UTF8.CodeUnit
{
    var urlEncodedBytes : [UTF8.CodeUnit]
    {
        if self == 0x20 //Change spaces to plus signs
        {
            return [0x2B]
        }
        else if self == 0x2A ||                //*
            self == 0x2D ||                    //-
            self == 0x2E ||                    //.
            (self >= 0x30 && self <= 0x39) ||  //0-9
            (self >= 0x41 && self <= 0x5A) ||  //A-Z
            self == 0x5F ||                    //_
            (self >= 0x61 && self <= 0x7A)     //a-z
        {
            return [self]
        }
        else
        {
            return Array(String(format: "%%%02X", self).utf8)
        }
    }
}

public extension NSManagedObjectContext
{
    func insertObject<T : NSManagedObject>() -> T where T : ManagedObjectType
    {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as? T else
        {
            fatalError("Unable to create an NSManagedObject of the requested type.")
        }
        return obj
    }
}

public protocol ManagedObjectType : class
{
    static var entityName : String { get }
    static var defaultSortDescriptors : [NSSortDescriptor] { get }
    static var defaultPredicate : NSPredicate { get }
    var managedObjectContext : NSManagedObjectContext? { get }
}

