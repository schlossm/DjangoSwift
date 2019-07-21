//
//  RESTManager.swift
//  RESTSwift
//
//  Created by Michael Schloss on 11/23/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation

private enum HTTPMethod : String
{
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

extension RESTManager
{
    public struct Error : Swift.Error
    {
        let code: Int
        let domain: String
        let description: String
        
        public static let urlComponentsError = Error(code: 30001, domain: "com.michaelschloss.restswift", description: "Could not form URLComponents object.")
        public static let urlComponentsURLError = Error(code: 30002, domain: "com.michaelschloss.restswift", description: "Could not form URL from URLComponents object.")
        
        public static let writeFailure = Error(code: 30101, domain: "com.michaelschloss.restswift", description: "Could not write task data to URL.  You may be out of space or not have write access to the directory.")
        public static let undecodableData = Error(code: 30102, domain: "com.michaelschloss.restswift", description: "The data download is undecodable by the given response type.")
        public static let badStatusCode = Error(code: 30103, domain: "com.michaelschloss.restswift", description: "Bad response code.")
        public static let jsonDecoderError = Error(code: 30104, domain: "com.michaelschloss.restswift", description: "JSONDecoder failed to decode the data.  Check the debugger output for more information.")
        public static let fileManagerError = Error(code: 30104, domain: "com.michaelschloss.restswift", description: "FileManager failed to copy the file.  Check the debugger output for more information.")
    }
}

public class RESTManager
{
    ///Returns the application's RESTManager instance
    public static let shared = RESTManager(configuration: URLSessionConfiguration.default)
    
    public var configuration: URLSessionConfiguration
    
    private lazy var processor = Processor(configuration: configuration, controller: self)
    
    /**
     The Authorization token used to communicate with the REST endpoints.  Set this after successfully logging a user in
     
     All future requests will include the authorization token
     */
    public var authToken : String?
    
    /**
     This is the name for the Authorization header.  It is usually `Token` or `Bearer`.
     
     i.e. `Authorization: Token {% AUTH_TOKEN %}`
     
     Defaults to `Token`
     */
    public static var tokenName = "Token"
    
    /**
     Defines a set of extra app/server specific headers that should be included with every request
     */
    public static var extraHeaders = [String : String]()
    
    /**
     The base URL on which all REST requests will build from.  This should be set prior to initiating any requests.
     
     If this is not set prior to a request being generated, undefined behavior will occur
     
     **NOTE:**
     
     You should not set `baseURL` more than once.  Doing so is considered a programmer error and will place a warning in the console
     */
    public var baseURL : URL
    {
        set
        {
            if _baseURL != nil
            {
                print("[WARNING]: You should not set RESTManager's baseURL property more than once during application lifetime.  This can lead to requests pointing to an incorrect URL.")
            }
            _baseURL = newValue
        }
        
        get
        {
            if let baseURL = _baseURL
            {
                return baseURL
            }
            print("[ERROR]: RESTManager does not have a `baseURL` set!  This will lead to undefined behavior and should be immediately corrected")
            return URL(fileURLWithPath: "/")
        }
    }
    
    private var _baseURL : URL?
    
    public init(configuration: URLSessionConfiguration = URLSessionConfiguration.default)
    {
        self.configuration = configuration
    }
    
    //MARK: - Private Helper Methods
    
    private func request(for url: URL, method: HTTPMethod) -> URLRequest
    {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let token = authToken
        {
            request.setValue("\(RESTManager.tokenName) \(token.urlEncoded)", forHTTPHeaderField: "Authorization")
        }
        for header in RESTManager.extraHeaders
        {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        request.setValue(baseURL.absoluteString, forHTTPHeaderField: "Referer")
        return request
    }
    
    private func buildURL<T : RESTRequest>(from request: T) throws -> URL
    {
        let initialURL = baseURL.appendingPathComponent(request.endpoint)
        guard var comps = URLComponents(url: initialURL, resolvingAgainstBaseURL: false) else
        {
            throw RESTManager.Error.urlComponentsError
        }
        
        if !request.queryItems.isEmpty
        {
            comps.queryItems = request.queryItems
        }
        
        guard let finalURL = comps.url else
        {
            throw RESTManager.Error.urlComponentsURLError
        }
        
        return finalURL
    }
}

//MARK: - REST

extension RESTManager
{
    public typealias RESTCompletion<T : RESTRequest> = (Result<T.Response, Error>, Int) -> Void
    public typealias FileDownloadCompletion<T : RESTFileDownloadRequest> = (Result<T.Response, Error>, Int) -> Void
    
    //MARK: - GET
    
    /**
     Initiates a GET request using the provided `RESTGETRequest` object.  This endpoint is to be used when the response from your server will be a JSON object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `RESTGETRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `RESTGETResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTGETResponse` object containing the retrieved object, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func get<T : RESTGETRequest>(request: T, acceptedStatusCodes: [Int] = Array(200...299), progress: inout Progress?, completion: @escaping RESTCompletion<T>) throws
    {
        let finalURL = try buildURL(from: request)
        print("GET \(finalURL.absoluteString)")
        
        let urlRequest = self.request(for: finalURL, method: .get)
        processor.other(urlRequest: urlRequest, progress: &progress) { result, statusCode in
            self.process(request: request, result: result, acceptedStatusCodes: acceptedStatusCodes, statusCode: statusCode, completion: completion)
        }
    }

    //MARK: - POST
    
    /**
     Initiates a POST request using the provided `RESTPOSTRequest` object.  This endpoint is to be used when the response from your server will be a JSON object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `RESTPOSTRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `RESTPOSTResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTPOSTResponse` object containing the retrieved object, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func post<T : RESTPOSTRequest>(request: T, acceptedStatusCodes: [Int] = Array(200...299), progress: inout Progress?, completion: @escaping RESTCompletion<T>) throws
    {
        let finalURL = try buildURL(from: request)
        var urlRequest = self.request(for: finalURL, method: .post)
        urlRequest.httpBody = request.postData
        print("POST \(finalURL)")
        try processor.post(urlRequest: urlRequest, progress: &progress) { result, statusCode in
            self.process(request: request, result: result, acceptedStatusCodes: acceptedStatusCodes, statusCode: statusCode, completion: completion)
        }
    }
    
    //MARK: - PUT
    
    /**
     Initiates a PUT request using the provided `RESTPUTRequest` object.  This endpoint is to be used when the response from your server will be a JSON object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `RESTPUTRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `RESTPUTResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTPUTResponse` object containing the retrieved object, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func put<T : RESTPUTRequest>(request: T, acceptedStatusCodes: [Int] = Array(200...299), progress: inout Progress?, completion: @escaping RESTCompletion<T>) throws
    {
        let finalURL = try buildURL(from: request)
        var urlRequest = self.request(for: finalURL, method: .put)
        urlRequest.httpBody = request.putData
        print("PUT \(finalURL)")
        try processor.put(urlRequest: urlRequest, progress: &progress) { result, statusCode in
            self.process(request: request, result: result, acceptedStatusCodes: acceptedStatusCodes, statusCode: statusCode, completion: completion)
        }
    }
    
    //MARK: - PATCH
    
    /**
     Initiates a PATCH request using the provided `RESTPATCHRequest` object.  This endpoint is to be used when the response from your server will be a JSON object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `RESTPATCHRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `RESTPATCHResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTPATCHResponse` object containing the retrieved object, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func patch<T : RESTPATCHRequest>(request: T, acceptedStatusCodes: [Int] = Array(200...299), progress: inout Progress?, completion: @escaping RESTCompletion<T>) throws
    {
        let finalURL = try buildURL(from: request)
        var urlRequest = self.request(for: finalURL, method: .patch)
        urlRequest.httpBody = request.patchData
        print("PATCH \(finalURL)")
        try processor.patch(urlRequest: urlRequest, progress: &progress) { result, statusCode in
            self.process(request: request, result: result, acceptedStatusCodes: acceptedStatusCodes, statusCode: statusCode, completion: completion)
        }
    }
    
    //MARK: - DELETE
    
    /**
     Initiates a DELETE request using the provided `RESTDELETERequest` object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `RESTDELETERequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `RESTDELETEResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTDELETEResponse` object containing the retrieved object, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func delete<T : RESTDELETERequest>(request: T, acceptedStatusCodes: [Int] = Array(200...299), progress: inout Progress?, completion: @escaping RESTCompletion<T>) throws
    {
        let finalURL = try buildURL(from: request)
        let urlRequest = self.request(for: finalURL, method: .delete)
        print("DELETE \(finalURL)")
        processor.other(urlRequest: urlRequest, progress: &progress) { result, statusCode in
            self.process(request: request, result: result, acceptedStatusCodes: acceptedStatusCodes, statusCode: statusCode, completion: completion)
        }
    }
}

//MARK: - Processing

extension RESTManager
{
    func process<T : RESTRequest>(request: T, result: Result<Data, Swift.Error>, acceptedStatusCodes: [Int], statusCode: Int, completion: RESTCompletion<T>)
    {
        guard acceptedStatusCodes.contains(statusCode) else
        {
            completion(.failure(.badStatusCode), statusCode)
            return
        }
        
        switch result
        {
        case .success(let data):
            do
            {
                let object = try JSONDecoder().decode(T.Response.DecodeType.self, from: data)
                if let response = T.Response.from(response: object)
                {
                    completion(.success(response), statusCode)
                }
                else if let response = T.Response.from(raw: data)
                {
                    completion(.success(response), statusCode)
                }
                else
                {
                    completion(.failure(.undecodableData), statusCode)
                }
            }
            catch
            {
                print(error)
                completion(.failure(.jsonDecoderError), statusCode)
            }
            
        case .failure(let error as NSError):
            print(error)
            completion(.failure(Error(code: error.code, domain: error.domain, description: error.localizedDescription)), statusCode)
        }
    }
    
    func process<T : RESTFileDownloadRequest>(request: T, result: Result<URL, Swift.Error>, acceptedStatusCodes: [Int], statusCode: Int, completion: FileDownloadCompletion<T>)
    {
        guard acceptedStatusCodes.contains(statusCode) else
        {
            completion(.failure(.badStatusCode), statusCode)
            return
        }
        
        switch result
        {
        case .success(let url):
            do
            {
                let newURL = FileManager.default.temporaryDirectory.appendingPathComponent("rs-downloaded-\(UUID().uuidString)")
                try FileManager.default.copyItem(at: url, to: newURL)
                if let response = T.Response.from(response: newURL)
                {
                    completion(.success(response), statusCode)
                }
                else
                {
                    completion(.failure(.undecodableData), statusCode)
                }
            }
            catch
            {
                print(error)
                completion(.failure(.fileManagerError), statusCode)
            }
            
        case .failure(let error as NSError):
            print(error)
            completion(.failure(Error(code: error.code, domain: error.domain, description: error.localizedDescription)), statusCode)
        }
    }
}
