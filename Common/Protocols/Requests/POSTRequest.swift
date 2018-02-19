//
//  POSTRequest.swift
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
public protocol POSTRequest : RESTRequest
{
    var postData : JSON? { get }
}

/**
 A POST request whos response will be a string, not a JSON object
 */
public protocol StringPOSTRequest : RESTStringRequest
{
    var postData : JSON? { get }
}
