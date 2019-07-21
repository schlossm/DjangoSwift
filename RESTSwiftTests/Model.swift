//
//  Model.swift
//  RESTSwiftTests
//
//  Created by Michael Schloss on 7/21/19.
//  Copyright © 2019 Michael Schloss. All rights reserved.
//

import Foundation
@testable import RESTSwift

struct TestUserModel : Decodable
{
    let id: String?
    let email: String
    let first_name: String
    let last_name: String
    let is_active: Bool
}

struct RESTTestGETRequest : RESTGETRequest
{
    typealias Response = RESTTestGETResponse
    
    let endpoint = "example/user/"
}

struct RESTTestGETResponse : RESTResponse
{
    typealias DecodeType = [String : TestUserModel]
    
    let model: DecodeType
    
    init(model: DecodeType)
    {
        self.model = model
    }
    
    static func from(response: DecodeType) -> RESTTestGETResponse? {
        return RESTTestGETResponse(model: response)
    }
}
