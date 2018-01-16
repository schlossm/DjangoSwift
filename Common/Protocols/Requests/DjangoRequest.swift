//
//  DjangoRequest.swift
//  DjangoSwift
//
//  Created by Michael Schloss on 11/23/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation
import CoreData

/**
 The basis of most Django requests in DjangoSwift.
 
 This protocol should only be adopted via one of the subtypes:
 * `DjangoGETRequest` and subtypes
 * `DjangoPUTRequest`
 * `DjangoPOSTRequest`
 * `DjangoPATCHRequest`
 * `DjangoDELETERequest`
 
 Each request will, at minimum, contain two things:
 1) A `Response typealias` that points to a class that conforms to `DjangoResponse` or one of its subtypes
 2) An `endpoint`.  This should **not** include the domain, only the path

 See `DjangoRequest` subtypes for more information into each specific type of request
*/
public protocol DjangoRequest
{
    ///A class that conforms to `DjangoResponse` or one of its subtypes
    associatedtype Response : DjangoResponse
    
    ///The endpoint in which to point this request.  This should **not** contain the domain name, only the path
    var endpoint : String { get }
}

/**
 A GET request whos response will be a string
 
 Each request will, at minimum, contain two things:
 1) A `Response typealias` that points to a class that conforms to `DjangoStringResponse` or one of its subtypes
 2) An `endpoint`.  This should **not** include the domain, only the path
 */
public protocol DjangoStringRequest
{
    ///A class that conforms to `DjangoStringResponse` or one of its subtypes
    associatedtype Response : DjangoStringResponse
    
    ///The endpoint in which to point this request.  This should **not** contain the domain name, only the path
    var endpoint : String { get }
}

/**
 A convenience protocol to guarantee a response is of type `PersistableDjangoResponse`
 */
public protocol PersistableDjangoRequest : DjangoRequest where Response : PersistableDjangoResponse { }
