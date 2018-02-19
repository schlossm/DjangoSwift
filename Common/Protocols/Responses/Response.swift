//
//  Response.swift
//  RESTSwift
//
//  Created by Michael Schloss on 12/8/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation
import CoreData

/**
 The basis for most REST responses in RESTSwift
 
 This protocol can be adpoted as is, or via one of the subtypes:
 * `PersistableRESTResponse`
 
 Each RESTResponse must contain a method `fromResponse(json: JSON)` that will return `nil` or an instance of `Self` depending on the validity of the given JSON data
 */
public protocol RESTResponse
{
    ///Returns `nil` or an instance of `Self` depending on validity of the given JSON data
    ///- Parameter json: A JSON object received from processing a `RESTRequest` or subtype
    static func fromResponse(json: JSON) -> Self?
}

/**
 An REST response who's response is a string
 
 Each RESTStringResponse must implement `fromResponse(string: String)` that will return `nil` or an instance of `Self` depending on the validity of the given string
 */
public protocol RESTStringResponse
{
    ///Returns `nil` or an instance of `Self` depending on validity of the given string
    ///- Parameter string: A String object received from processing a `RESTStringRequest`
    static func fromResponse(string: String) -> Self?
}

/**
 An REST response who's returned JSON data should be persisted to CoreData
 
 Each `PersistableRESTResponse` must contain a typealias to the corresponding `NSManagedObject` subclass as well as an implementation of `copyProperties(to record: Model)` method
 */
public protocol PersistableRESTResponse : RESTResponse
{
    ///A typealias to a Core Data model
    associatedtype Model : NSManagedObject
    
    ///This method will receive a CoreData object and should copy any pertinant properities over to the object.  If the copy cannot be completed, this method should throw an error
    ///- Parameter record: A CoreData object in which to copy pertinant properties
    func copyProperties(to record: Model) throws
}
