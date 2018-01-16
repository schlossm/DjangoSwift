//
//  DjangoGETRequest.swift
//  DjangoSwift
//
//  Created by Michael Schloss on 12/8/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

/**
 A GET request
 
 Allows for the specification of URI key-value pairs
 */
public protocol DjangoGETRequest : DjangoRequest
{
    ///A dictionary specifying URI key-value pairs
    var queryParameters : [String : String]? { get }
}

/**
 Convenience GET request that denotes a single object should be expected from the specified endpoint
 */
public protocol DjangoSingleObjectRequest : DjangoGETRequest { }

public extension DjangoGETRequest
{
    var queryParameters : [String: String]? { return nil }
}

extension DjangoGETRequest
{
    var queryItems : [URLQueryItem]
    {
        return (queryParameters ?? [:]).map { URLQueryItem(name: $0, value: $1) }
    }
}
