//
//  RESTPOSTRequest.swift
//  RESTSwift
//
//  Created by Michael Schloss on 12/8/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

/**
 A POST request
 
 Allows for the specification of POST data
 */
public protocol RESTPOSTRequest : RESTRequest
{
    var postData : JSON? { get }
}

/**
 A POST request whos response will be a string, not a JSON object
 */
public protocol RESTStringPOSTRequest : RESTStringRequest
{
    var postData : JSON? { get }
}
