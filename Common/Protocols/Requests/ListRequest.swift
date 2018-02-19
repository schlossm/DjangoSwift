//
//  ListRequest.swift
//  RESTSwift
//
//  Created by Michael Schloss on 12/8/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

/**
 A GET request that specifies properties for returning lists of an object
 
 In the event the list is too long for one page of objects, this request returns all objects from the specified page with the specified page size
 */
public protocol ListRequest : GETRequest
{
    ///The key to sort by.  Defaults to "`id`"
    static var sortKey : String { get }
    
    ///Specifies the ordering of objects returned.  Defaults to `true`
    static var orderedAscending : Bool { get }
    
    ///Specifies the number of entries to return per page.  Defaults to `25`
    static var pageSize : Int { get }
    
    ///Specified the page number
    var pageNumber : Int { get }
    
    ///Convenience method to create a new request for the next page
    func requestForNextPage() -> Self?
}

/**
 A `RESTListRequest` that loads all pages of data
 */
public protocol ListAllRequest : ListRequest
{
    init(pageNumber: Int)
}

public extension ListRequest
{
    public static var pageSize : Int
    {
        return 25
    }
    
    public static var sortKey : String
    {
        return "id"
    }
    
    public static var orderedAscending : Bool
    {
        return true
    }
    
    public static var sortDescriptor : NSSortDescriptor
    {
        return NSSortDescriptor(key: Self.sortKey, ascending: Self.orderedAscending)
    }
    
    public func requestForNextPage() -> Self?
    {
        return nil
    }
}

public extension ListRequest
{
    var queryItems : [URLQueryItem]
    {
        var params = queryParameters ?? [:]
        params["page"] = String(pageNumber)
        params["page_size"] = String(Self.pageSize)
        params["ordering"] = Self.orderedAscending ? Self.sortKey : "-\(Self.sortKey)"
        
        return params.map { URLQueryItem(name: $0, value: $1) }
    }
}

public extension ListAllRequest
{    
    public func requestForNextPage() -> Self?
    {
        return Self(pageNumber: pageNumber + 1)
    }
}
