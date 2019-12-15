//
//  RESTResponse.swift
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
    associatedtype RequestType: RESTRequest where RequestType.ResponseType == Self
    associatedtype DecodeType : Decodable
    
    ///Returns `nil` or an instance of `Self` depending on validity of the given JSON data
    ///- Parameter json: A JSON object received from processing a `RESTRequest` or subtype
    static func from(response: DecodeType, request: RequestType) -> Self?
    
    static func from(raw: Data) -> Self?
}

public extension RESTResponse
{
    static func from(raw: Data) -> Self?
    {
        return nil
    }
}

public protocol RESTFileDownloadResponse
{
    associatedtype RequestType: RESTFileDownloadRequest where RequestType.ResponseType == Self
    
    static func from(response: URL, request: RequestType) -> Self?
}
