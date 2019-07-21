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
    var postData : Data? { get }
}
