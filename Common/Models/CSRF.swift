//
//  CSRF.swift
//  DjangoSwift
//
//  Created by Michael Schloss on 11/26/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

final class CSRFRequest : NSObject, DjangoStringRequest
{
    var endpoint : String = DjangoManager.csrfEndpoint
    var authToken : String?
    typealias Response = CSRFResponse
    
    override init() { }
    
    init(authToken: String)
    {
        self.authToken = authToken
    }
}

final class CSRFResponse : DjangoStringResponse
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
