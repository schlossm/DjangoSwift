//
//  CSRF.swift
//  RESTSwift
//
//  Created by Michael Schloss on 11/26/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

final class CSRFRequest : NSObject, RESTStringRequest
{
    var endpoint : String = RESTManager.csrfEndpoint
    var authToken : String?
    typealias Response = CSRFResponse
    
    override init() { }
    
    init(authToken: String)
    {
        self.authToken = authToken
    }
}

final class CSRFResponse : RESTStringResponse
{
    let token : String
    
    init(token: String)
    {
        self.token = token
    }
    
    static func fromResponse(string: String) -> CSRFResponse?
    {
        return CSRFResponse(token: string)
    }
}
