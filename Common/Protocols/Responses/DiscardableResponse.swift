//
//  DiscardableResponse.swift
//  DjangoSwift
//
//  Created by Michael Schloss on 12/8/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

/**
 A convenience response class that specifies the response can be discarded
 */
public final class DiscardableResponse : DjangoResponse
{
    public static func fromResponse(json: JSON) -> DiscardableResponse?
    {
        return DiscardableResponse()
    }
}
