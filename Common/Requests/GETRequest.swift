//
//  RESTGETRequest.swift
//  RESTSwift
//
//  Created by Michael Schloss on 12/8/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

/**
 A GET request
 
 Allows for the specification of URI key-value pairs
 */
public protocol RESTGETRequest : RESTRequest { }

extension RESTGETRequest
{
    var queryItems : [URLQueryItem]
    {
        return (queryParameters ?? [:]).map { URLQueryItem(name: $0, value: $1) }
    }
}
