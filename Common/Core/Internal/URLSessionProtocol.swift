//
//  URLSessionProtocol.swift
//  RESTSwift
//
//  Created by Michael Schloss on 12/22/19.
//  Copyright © 2019 Michael Schloss. All rights reserved.
//

import Foundation

@objc protocol URLSessionTaskDelegateProtocol : URLSessionTaskDelegate {
    @available(iOS 7.0, *)
    @objc optional func urlSession(_ session: URLSessionProtocol, task: NSObject & URLSessionTaskProtocol, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    
    @available(iOS 10.0, *)
    @objc optional func urlSession(_ session: URLSessionProtocol, task: NSObject & URLSessionTaskProtocol, didFinishCollecting metrics: URLSessionTaskMetrics)
    
    @available(iOS 7.0, *)
    @objc optional func urlSession(_ session: URLSessionProtocol, task: NSObject & URLSessionTaskProtocol, didCompleteWithError error: Error?)
}

@objc protocol URLSessionDataDelegateProtocol : URLSessionTaskDelegateProtocol, URLSessionDataDelegate {
    @available(iOS 7.0, *)
    @objc optional func urlSession(_ session: URLSessionProtocol, dataTask: NSObject & URLSessionTaskProtocol, didReceive data: Data)
}

@objc protocol URLSessionDownloadDelegateProtocol : URLSessionTaskDelegateProtocol, URLSessionDownloadDelegate {
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSessionProtocol, downloadTask: NSObject & URLSessionTaskProtocol, didFinishDownloadingTo location: URL)
    
    @available(iOS 7.0, *)
    @objc optional func urlSession(_ session: URLSessionProtocol, downloadTask: NSObject & URLSessionTaskProtocol, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
}

@objc protocol URLSessionTaskProtocol: NSObjectProtocol {
    @available(iOS, introduced: 11.0)
    var progress: Progress { get }
    
    var response: URLResponse? { get }
    
    func resume()
}

@objc protocol URLSessionProtocol: NSObjectProtocol {
    var delegate: URLSessionDelegate? { get }
    var delegateQueue: OperationQueue { get }
    
    @objc(sessionWithConfiguration:delegate:delegateQueue:)
    init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?)
    
    func sessionDataTask(with request: URLRequest) -> URLSessionTaskProtocol
    
    func sessionUploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionTaskProtocol
    
    func sessionDownloadTask(with request: URLRequest) -> URLSessionTaskProtocol
}

extension URLSessionTask: URLSessionTaskProtocol { }

extension URLSession: URLSessionProtocol {
    func sessionDataTask(with request: URLRequest) -> URLSessionTaskProtocol {
        let sessionTask: URLSessionDataTask = self.dataTask(with: request)
        return sessionTask
    }
    
    func sessionUploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionTaskProtocol {
        let sessionTask: URLSessionUploadTask = self.uploadTask(with: request, fromFile: fileURL)
        return sessionTask
    }
    
    func sessionDownloadTask(with request: URLRequest) -> URLSessionTaskProtocol {
        let sessionTask: URLSessionDownloadTask = self.downloadTask(with: request)
        return sessionTask
    }
}
