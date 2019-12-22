//
//  MockURLSession.swift
//  RESTSwift
//
//  Created by Michael Schloss on 12/22/19.
//  Copyright © 2019 Michael Schloss. All rights reserved.
//

import Foundation

class MockURLSessionDataTask: NSObject, URLSessionTaskProtocol {
    var progress = Progress()
    private var attachedSession: URLSessionProtocol
    var response: URLResponse? = nil
    
    typealias Delegate = URLSessionDataDelegateProtocol & URLSessionTaskDelegateProtocol
    
    private let jsonURL: URL?
    private weak var delegate: Delegate?
    
    init(jsonURL: URL? = nil, delegate: Delegate?, urlSession: URLSessionProtocol) {
        self.jsonURL = jsonURL
        self.delegate = delegate
        attachedSession = urlSession
    }
    
    func resume() {
        guard let jsonURL = jsonURL, let data = try? Data(contentsOf: jsonURL) else {
            response = HTTPURLResponse(url: self.jsonURL ?? URL(fileURLWithPath: ""), statusCode: 400, httpVersion: "2.0", headerFields: nil)
            delegate?.urlSession?(attachedSession, task: self, didCompleteWithError: NSError(domain: "com.restswift.mock", code: -1, userInfo: nil))
            return
        }
        response = HTTPURLResponse(url: jsonURL, statusCode: 200, httpVersion: "2.0", headerFields: nil)
        delegate?.urlSession?(attachedSession, dataTask: self, didReceive: data)
        delegate?.urlSession?(attachedSession, task: self, didCompleteWithError: nil)
    }
}

class MockURLSessionDownloadTask: NSObject, URLSessionTaskProtocol {
    var progress = Progress()
    var response: URLResponse? = nil
    private var attachedSession: URLSessionProtocol
    
    typealias Delegate = URLSessionDownloadDelegateProtocol & URLSessionTaskDelegateProtocol
    
    private weak var delegate: Delegate?
    
    init(delegate: Delegate?, urlSession: URLSessionProtocol) {
        self.delegate = delegate
        attachedSession = urlSession
    }
    
    func resume() {
        delegate?.urlSession(attachedSession, downloadTask: self, didFinishDownloadingTo: URL(fileURLWithPath: "fake/path.img"))
    }
}

class MockURLSessionUploadTask: MockURLSessionDataTask { }

class MockURLSession: NSObject, URLSessionProtocol {
    var delegate: URLSessionDelegate?
    var delegateQueue = OperationQueue()
    
    required init(configuration: URLSessionConfiguration) {
        delegate = nil
    }
    
    required init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) {
        self.delegate = delegate
        if let queue = queue {
            delegateQueue = queue
        }
    }
    
    private func getEndpoint(from: URL?) -> String {
        return from?.path ?? ""
    }
    
    func sessionDataTask(with request: URLRequest) -> URLSessionTaskProtocol {
        return MockURLSessionDataTask(jsonURL: RESTManager.mockConfiguration[getEndpoint(from: request.url)], delegate: delegate as? MockURLSessionDataTask.Delegate, urlSession: self)
    }
    
    func sessionUploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionTaskProtocol {
        return MockURLSessionUploadTask(delegate: delegate as? MockURLSessionDataTask.Delegate, urlSession: self)
    }
    
    func sessionDownloadTask(with request: URLRequest) -> URLSessionTaskProtocol {
        return MockURLSessionDownloadTask(delegate: delegate as? MockURLSessionDownloadTask.Delegate, urlSession: self)
    }
}
