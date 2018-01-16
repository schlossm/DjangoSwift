//
//  String+StrippingPadding.swift
//
//
//  Created by Michael Schloss on 11/08/2017.
//  Copyright (c) 2017 Michael Schloss. All rights reserved.
//

//Trims a string only along a certain side.  Useful for IDs and calculator displays

import UIKit

///The side to trim along
@objc enum Side : Int
{
    ///The beginning of the string
    case beginning
    
    ///The end of the string
    case end
}

extension String
{
    /**
     Trims the string along a certain side
     
     - Parameter side: The side of the string to trim along
     - Parameter paddingCharacter: The character to trim.  Defaults to `0`
     - Returns: A string trimmed along the side specified
     */
    func strippingPadding(off side: Side, paddingCharacter: Character = "0") -> String
    {
        guard !isEmpty else { return self }
        
        var newString = self
        while !newString.isEmpty, (side == .beginning ? newString.first : newString.last) == paddingCharacter
        {
            newString = String(side == .beginning ? newString.dropFirst() : newString.dropLast())
        }
        
        return newString
    }
}
