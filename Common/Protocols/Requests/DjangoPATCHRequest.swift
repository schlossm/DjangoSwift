//
//  DjangoPATCHRequest.swift
//  DjangoSwift
//
//  Created by Michael Schloss on 12/8/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

/**
 A PATCH request
 
 Allows for the specification of PATCH data
 */
public protocol DjangoPATCHRequest : DjangoRequest
{
    var patchData : JSON? { get }
}
