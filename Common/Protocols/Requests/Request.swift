//
//  Request.swift
//  RESTSwift
//
//  Created by Michael Schloss on 11/23/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation
import CoreData

public protocol Header
{
    ///Extra headers to add to the HTTP URL Request for this request
    var extraHeaders : [String : String]? { get }
}

/**
 The basis of most REST requests in RESTSwift.
 
 This protocol should only be adopted via one of the subtypes:
 * `GETRequest` and subtypes
 * `PUTRequest`
 * `POSTRequest`
 * `PATCHRequest`
 * `DELETERequest`
 
 Each request will, at minimum, contain two things:
 1) A `Response typealias` that points to a class that conforms to `RESTResponse` or one of its subtypes
 2) An `endpoint`.  This should **not** include the domain, only the path

 See `RESTRequest` subtypes for more information into each specific type of request
*/
public protocol RESTRequest : Header
{
    ///A class that conforms to `RESTResponse` or one of its subtypes
    associatedtype Response : RESTResponse
    
    ///The endpoint in which to point this request.  This should **not** contain the domain name, only the path
    var endpoint : String { get }
}

/**
 A GET request whos response will be a string
 
 Each request will, at minimum, contain two things:
 1) A `Response typealias` that points to a class that conforms to `RESTStringResponse` or one of its subtypes
 2) An `endpoint`.  This should **not** include the domain, only the path
 */
public protocol RESTStringRequest : Header
{
    ///A class that conforms to `RESTStringResponse` or one of its subtypes
    associatedtype Response : RESTStringResponse
    
    ///The endpoint in which to point this request.  This should **not** contain the domain name, only the path
    var endpoint : String { get }
}

/**
 A convenience protocol to guarantee a response is of type `PersistableRESTResponse`
 */
public protocol PersistableRESTRequest : RESTRequest where Response : PersistableRESTResponse { }

public extension RESTRequest
{
    var extraHeaders : [String : String]? { return nil }
}

public extension RESTStringRequest
{
    var extraHeaders : [String : String]? { return nil }
}
