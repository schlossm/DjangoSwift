//
//  RESTRequest.swift
//  RESTSwift
//
//  Created by Michael Schloss on 11/23/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

/**
 The basis of most REST requests in RESTSwift.
 
 This protocol should only be adopted via one of the subtypes:
 * `RESTGETRequest` and subtypes
 * `RESTPUTRequest`
 * `RESTPOSTRequest`
 * `RESTPATCHRequest`
 * `RESTDELETERequest`
 
 Each request will, at minimum, contain two things:
 1) A `Response typealias` that points to a class that conforms to `RESTResponse` or one of its subtypes
 2) An `endpoint`.  This should **not** include the domain, only the path

 See `RESTRequest` subtypes for more information into each specific type of request
*/
public protocol RESTRequest
{
    ///A class that conforms to `RESTResponse` or one of its subtypes
    associatedtype Response : RESTResponse
    
    ///The endpoint in which to point this request.  This should **not** contain the domain name, only the path
    var endpoint : String { get }
}

/**
 Defines a request specific to downloading files.
 
 Each request will, at minimum, contain two things:
 1) A `Response typealias` that points to a class that conforms to `RESTFileDownloadResponse`
 2) An `endpoint`.  This should **not** include the domain, only the path
 */
public protocol RESTFileDownloadRequest
{
    ///A class that conforms to `RESTResponse` or one of its subtypes
    associatedtype Response : RESTFileDownloadResponse
    
    ///The endpoint in which to point this request.  This should **not** contain the domain name, only the path
    var endpoint : String { get }
}
