//
//  RESTPUTRequest.swift
//  RESTSwift
//
//  Created by Michael Schloss on 12/8/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

/**
 A PUT request
 
 Allows for the specification of PUT data
 */
public protocol RESTPUTRequest : RESTRequest
{
    var putData : JSON? { get }
}
