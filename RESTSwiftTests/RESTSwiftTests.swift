//
//  RESTSwiftTests.swift
//  RESTSwiftTests
//
//  Created by Michael Schloss on 7/21/19.
//  Copyright © 2019 Michael Schloss. All rights reserved.
//

import XCTest
@testable import RESTSwift

class RESTSwiftTests : XCTestCase
{
    static let session = RESTManager(configuration: URLSessionConfiguration.background(withIdentifier: "com.michaelschloss.restswift.tests"))
    override class func setUp()
    {
        super.setUp()
        RESTSwiftTests.session.baseURL = URL(string: "https://staging.mascomputech.com")!
        RESTManager.mockConfiguration = ["/example/user": Bundle(for: RESTSwiftTests.self).url(forResource: "exampleUser", withExtension: "json")!]
    }
    
    func testGET() throws
    {
        let _expectation = expectation(description: "GET Request")
        var progress: Progress?
        try RESTSwiftTests.session.get(request: RESTTestGETRequest(), progress: &progress) { result, statusCode in
            XCTAssertEqual(statusCode, 200)
            switch result
            {
            case .failure(let error):
                XCTFail("Encountered error: \(error)")
                
            case .success(_): break
            }
            
            _expectation.fulfill()
        }
        wait(for: [_expectation], timeout: 10.0)
    }
}
