//
//  Processor.swift
//  RESTSwift
//
//  Created by Michael Schloss on 6/25/19.
//  Copyright © 2019 Michael Schloss. All rights reserved.
//

import Foundation

extension Processor
{
    fileprivate class _Tracker
    {
        static let shared = _Tracker()
        
        private var downloadingModels = [ProcessorRESTModel]()
        private var downloadingFiles = [ProcessorFileDownloadModel]()
        private let queue = DispatchQueue(label: "com.michaelschloss.restswift._tracking")
        
        func append(_ model: ProcessorRESTModel)
        {
            queue.sync { downloadingModels.append(model) }
        }
        
        func append(_ model: ProcessorFileDownloadModel)
        {
            queue.sync { downloadingFiles.append(model) }
        }
        
        subscript(rest key: URLSessionTask) -> ProcessorRESTModel?
        {
            queue.sync { downloadingModels.first { $0.urlSessionTask == key } }
        }
        
        subscript(file key: URLSessionTask) -> ProcessorFileDownloadModel?
        {
            queue.sync { downloadingFiles.first { $0.urlSessionTask == key } }
        }
        
        func remove(_ task: URLSessionTask)
        {
            queue.sync {
                downloadingModels.removeAll { $0.urlSessionTask == task }
                downloadingFiles.removeAll { $0.urlSessionTask == task }
            }
        }
    }
}

class Processor : NSObject
{
    private var configuration: URLSessionConfiguration
    private lazy var session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    
    private var controller: RESTManager
    
    init(configuration: URLSessionConfiguration, controller: RESTManager)
    {
        self.configuration = configuration
        self.controller = controller
    }
    
    func write(data: Data) -> URL?
    {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("rspu-\(UUID().uuidString)")
        do
        {
            try data.write(to: url)
        }
        catch
        {
            print(error)
            return nil
        }
        return url
    }
    
    func post(urlRequest: URLRequest, progress: inout Progress?, completion: @escaping ProcessorRESTModelCompletion) throws
    {
        guard let localURL = write(data: urlRequest.httpBody ?? Data()) else
        {
            throw RESTManager.Error.writeFailure
        }
        upload(urlRequest: urlRequest, localURL: localURL, progress: &progress, completion: completion)
    }
    
    func put(urlRequest: URLRequest, progress: inout Progress?, completion: @escaping ProcessorRESTModelCompletion) throws
    {
        guard let localURL = write(data: urlRequest.httpBody ?? Data()) else
        {
            throw RESTManager.Error.writeFailure
        }
        upload(urlRequest: urlRequest, localURL: localURL, progress: &progress, completion: completion)
    }
    
    func patch(urlRequest: URLRequest, progress: inout Progress?, completion: @escaping ProcessorRESTModelCompletion) throws
    {
        guard let localURL = write(data: urlRequest.httpBody ?? Data()) else
        {
            throw RESTManager.Error.writeFailure
        }
        upload(urlRequest: urlRequest, localURL: localURL, progress: &progress, completion: completion)
    }
    
    func other(urlRequest: URLRequest, progress: inout Progress?, completion: @escaping ProcessorRESTModelCompletion)
    {
        
        let task = session.dataTask(with: urlRequest)
        let model = ProcessorRESTModel(task: task, completion: completion)
        if #available(iOS 11.0, *) {
            progress = task.progress
        } else {
            progress = model.progress
        }
        _Tracker.shared.append(model)
        task.resume()
    }
    
    func upload(urlRequest: URLRequest, localURL: URL, progress: inout Progress?, completion: @escaping ProcessorRESTModelCompletion)
    {
        let task = session.uploadTask(with: urlRequest, fromFile: localURL)
        let model = ProcessorRESTModel(task: task, completion: completion)
        if #available(iOS 11.0, *) {
            progress = task.progress
        } else {
            progress = model.progress
        }
        _Tracker.shared.append(model)
        task.resume()
    }
    
    func download(urlRequest: URLRequest, progress: inout Progress?, completion: @escaping ProcessorFileDownloadCompletion)
    {
        let task = session.downloadTask(with: urlRequest)
        let model = ProcessorFileDownloadModel(task: task, completion: completion)
        if #available(iOS 11.0, *) {
            progress = task.progress
        } else {
            progress = model.progress
        }
        _Tracker.shared.append(model)
        task.resume()
    }
}

extension Processor : URLSessionTaskDelegate, URLSessionDownloadDelegate, URLSessionDelegate, URLSessionDataDelegate
{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        guard let model = _Tracker.shared[file: downloadTask] else { return }
        model.completion(.success(location), (downloadTask.response as? HTTPURLResponse)?.statusCode ?? -1)
        _Tracker.shared.remove(downloadTask)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        guard let model = _Tracker.shared[file: downloadTask] else { return }
        if !model.didSetTotalDownloadUnitCount
        {
            model.didSetTotalDownloadUnitCount = true
            model.progress.totalUnitCount += totalBytesExpectedToWrite
        }
        model.progress.completedUnitCount += bytesWritten
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        if let error = error
        {
        if let model = _Tracker.shared[file: task]
        {
            model.completion(.failure(error), (task.response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        else if let model = _Tracker.shared[rest: task]
        {
            model.completion(.failure(error), (task.response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        }
        else
        {
            if let model = _Tracker.shared[rest: task]
            {
                model.completion(.success(model.data), (task.response as? HTTPURLResponse)?.statusCode ?? -1)
            }
        }
        _Tracker.shared.remove(task)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    {
        guard let model = _Tracker.shared[rest: dataTask] else { return }
        model.data += data
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let model = _Tracker.shared[rest: task] else { return }
        if !model.didSetTotalUnitCountUpload
        {
            model.didSetTotalUnitCountUpload = true
            model.progress.totalUnitCount += totalBytesExpectedToSend
        }
        model.progress.completedUnitCount += bytesSent
    }
}
