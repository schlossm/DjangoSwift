//
//  DiscardableResponse.swift
//  RESTSwift
//
//  Created by Michael Schloss on 12/8/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

/**
 A convenience response class that specifies the response data can be discarded.  The HTTP status code is still returned
 */
public final class DiscardableResponse : RESTResponse
{
    public static func fromResponse(json: JSON) -> DiscardableResponse?
    {
        return DiscardableResponse()
    }
}
