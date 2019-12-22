//
//  Tracking.swift
//  RESTSwift
//
//  Created by Michael Schloss on 6/25/19.
//  Copyright © 2019 Michael Schloss. All rights reserved.
//

import Foundation

typealias ProcessorRESTModelCompletion = (Result<Data, Error>, Int) -> Void
typealias ProcessorFileDownloadCompletion = (Result<URL, Error>, Int) -> Void

class ProcessorModel
{
    let urlSessionTask: URLSessionTaskProtocol
    let progress = Progress()
    
    var didSetTotalUnitCountUpload = false
    var didSetTotalDownloadUnitCount = false
    
    init(task: URLSessionTaskProtocol)
    {
        urlSessionTask = task
    }
}

class ProcessorRESTModel : ProcessorModel
{
    var completion: ProcessorRESTModelCompletion
    var data = Data()
    
    init(task: URLSessionTaskProtocol, completion: @escaping ProcessorRESTModelCompletion) {
        self.completion = completion
        super.init(task: task)
    }
}

class ProcessorFileDownloadModel : ProcessorModel
{
    var completion: ProcessorFileDownloadCompletion
    
    init(task: URLSessionTaskProtocol, completion: @escaping ProcessorFileDownloadCompletion) {
        self.completion = completion
        super.init(task: task)
    }
}
