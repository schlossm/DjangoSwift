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

public class RESTManager
{
    ///Returns the application's RESTManager instance
    public static let shared = RESTManager()
    
    ///Determines whether endpoints require a Cross-Site Request Forgery token to be transmitted with each `POST`.  Defaults to `true`
    public static var requiresCSRFToken = true
    
    /**
     Set this property during `applicationDidFinishLaunching(_ application: UIApplication)` to initialize RESTSwift's CoreData stack
     
     This variable should be set to your `xcdatamodeld`'s name (excluding ".xcdatamodeld")
     */
    public static var coreDataModelDName = ""
    {
        didSet
        {
            RESTCoreData.shared.loadStore(withName: coreDataModelDName)
        }
    }
    
    /**
     If your REST endpoints require a CSRF token, this endpoint will be called in order to obtain the token
     
     This URL should respond with an HTML template that contains only the csrf token.  RESTSwift will decode the CSRF token for use
     
     Defaults to `csrf/`
     */
    public static var csrfEndpoint = "csrf/"
    
    fileprivate var csrfToken : String?
    private var _baseURL : URL?
    
    /**
     The Authorization token used to communicate with the REST endpoints.  Set this after successfully logging a user in
     
     All future requests will include the authorization token
     */
    public var authToken : String?
    
    ///Tells RESTManager whether or not `authToken` will need to be converted to Base64.  Defaults to `false`, meaning RESTManager will convert the token to Base64
    public var isAuthTokenBase64Encoded = false
    
    /**
     This is the name for the Authorization header.  It is usually `Token` or `Bearer`.
     
     i.e. `Authorization: Token {% AUTH_TOKEN %}`
     
     Defaults to `Token`
     */
    public static var tokenName = "Token"
    
    ///Defines a set of extra app/server specific headers that should be included with every request
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
    
    private init() { }
}

//MARK: - Private Helper Methods

extension RESTManager
{
    private func request<T : Header>(for url: URL, request: T, method: HTTPMethod) -> URLRequest
    {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        if let token = authToken
        {
            urlRequest.setValue("\(RESTManager.tokenName) \(isAuthTokenBase64Encoded ? token : token.urlEncoded)", forHTTPHeaderField: "Authorization")
        }
        if let csrfKey = csrfToken
        {
            urlRequest.setValue(csrfKey.urlEncoded, forHTTPHeaderField: "X-CSRFToken")
        }
        for header in RESTManager.extraHeaders
        {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        for header in (request.extraHeaders ?? [:])
        {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        urlRequest.setValue(RESTManager.shared.baseURL.absoluteString, forHTTPHeaderField: "Referer")
        return urlRequest
    }
    
    private func printDebugInformation(forResponse response: URLResponse?, responseData: Data?, withRequest request: URLRequest?)
    {
        #if DEBUG
            if let data = request?.httpBody
            {
                print(String(data: data, encoding: .utf8) ?? "No Body Data")
            }
            print(request?.allHTTPHeaderFields ?? "No Request Headers")
            print(response ?? "No Response")
            print(responseData ?? "No Response Data")
            if let data = responseData, let string = String(data: data, encoding: .utf8)
            {
                print(string)
            }
        #endif
    }
}

//MARK: - REST

extension RESTManager
{
    //MARK: - GET
    
    /**
     Initiates a GET request using the provided `RESTStringRequest` object.  This endpoint is to be used when the response from your server will be a String
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `RESTStringRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `200`
     - Parameter completion: A closure that accepts an `RESTStringResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTStringResponse` object containing the retrieved String, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func get<T : RESTStringRequest>(request: T, acceptedStatusCodes: [Int] = [200], completion: @escaping (_ response: T.Response?, _ statusCode: Int) -> Void)
    {
        let urlRequest = self.request(for: baseURL.appendingPathComponent(request.endpoint), request: request, method: .get)
        print("GET \(baseURL.appendingPathComponent(request.endpoint).absoluteString)")
        perform(request: request, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion)
    }
    
    /**
     Initiates a GET request using the provided `GETRequest` object.  This endpoint is to be used when the response from your server will be a JSON object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `GETRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `RESTGETResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTGETResponse` object containing the retrieved object, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func get<T : GETRequest>(request: T, acceptedStatusCodes: [Int] = [200], completion: @escaping (_ response: T.Response?, _ statusCode: Int) -> Void)
    {
        let initialURL = baseURL.appendingPathComponent(request.endpoint)
        guard var comps = URLComponents(url: initialURL, resolvingAgainstBaseURL: true) else
        {
            completion(nil, -1)
            return
        }
        
        if !request.queryItems.isEmpty
        {
            comps.queryItems = request.queryItems
        }
        
        guard let finalURL = comps.url else
        {
            completion(nil, -1)
            return
        }
        print("GET \(finalURL.absoluteString)")
        
        let urlRequest = self.request(for: finalURL, request: request, method: .get)
        perform(request: request, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion)
    }
    
    /**
     Initiates a GET request using the provided `ListRequest` object.  This endpoint is to be used when the response from your server will be a JSON object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `ListRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `ListRequest` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An array of `ListRequest` objects containing the retrieved objects, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func getList<T : ListRequest>(request: T, acceptedStatusCodes: [Int] = [200], completion: @escaping (_ response: [T.Response]?, _ statusCode: Int) -> Void)
    {
        let initialURL = baseURL.appendingPathComponent(request.endpoint)
        guard var comps = URLComponents(url: initialURL, resolvingAgainstBaseURL: true) else
        {
            completion(nil, -1)
            return
        }
        
        comps.queryItems = request.queryItems
        
        guard let finalURL = comps.url else
        {
            completion(nil, -1)
            return
        }
        print("GET \(finalURL.absoluteString)")
        
        let urlRequest = self.request(for: finalURL, request: request, method: .get)
        perform(request: request, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion)
    }

    //MARK: - POST
    
    /**
     Initiates a POST request using the provided `StringPOSTRequest` object.  This endpoint is to be used when the response from your server will be a String
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `StringPOSTRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `200`
     - Parameter completion: A closure that accepts an `RESTStringResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTStringResponse` object containing the retrieved String, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func post<T : StringPOSTRequest>(request: T, acceptedStatusCodes: [Int] = Array(200...299), completion: @escaping (_ response: T.Response?, _ statusCode: Int) -> Void)
    {
        var urlRequest = self.request(for: baseURL.appendingPathComponent(request.endpoint), request: request, method: .post)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = request.postData?.formURLEncoded.data(using: .ascii)
        print("POST \(baseURL.appendingPathComponent(request.endpoint).absoluteString)")
        perform(request: request, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion)
    }
    
    /**
     Initiates a POST request using the provided `POSTRequest` object.  This endpoint is to be used when the response from your server will be a JSON object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `POSTRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `RESTPOSTResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTPOSTResponse` object containing the retrieved object, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func post<T : POSTRequest>(request: T, acceptedStatusCodes: [Int] = Array(200...299), completion: @escaping (_ response: T.Response?, _ statusCode: Int) -> Void)
    {
        var urlRequest = self.request(for: baseURL.appendingPathComponent(request.endpoint), request: request, method: .post)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = request.postData?.formURLEncoded.data(using: .ascii)
        print("POST \(baseURL.appendingPathComponent(request.endpoint).absoluteString)")
        perform(request: request, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion)
    }
    
    //MARK: - PUT
    
    /**
     Initiates a PUT request using the provided `PUTRequest` object.  This endpoint is to be used when the response from your server will be a JSON object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `PUTRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `RESTPUTResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTPUTResponse` object containing the retrieved object, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func put<T : PUTRequest>(request: T, acceptedStatusCodes: [Int] = Array(200...299), completion: @escaping (_ response: T.Response?, _ statusCode: Int) -> Void)
    {
        var urlRequest = self.request(for: baseURL.appendingPathComponent(request.endpoint), request: request, method: .put)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = request.putData?.formURLEncoded.data(using: .ascii)
        print("PUT \(baseURL.appendingPathComponent(request.endpoint).absoluteString)")
        perform(request: request, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion)
    }
    
    //MARK: - PATCH
    
    /**
     Initiates a PATCH request using the provided `PATCHRequest` object.  This endpoint is to be used when the response from your server will be a JSON object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `PATCHRequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `RESTPATCHResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTPATCHResponse` object containing the retrieved object, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func patch<T : PATCHRequest>(request: T, acceptedStatusCodes: [Int] = Array(200...299), completion: @escaping (_ response: T.Response?, _ statusCode: Int) -> Void)
    {
        var urlRequest = self.request(for: baseURL.appendingPathComponent(request.endpoint), request: request, method: .patch)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = request.patchData?.formURLEncoded.data(using: .ascii)
        print("PATCH \(baseURL.appendingPathComponent(request.endpoint).absoluteString)")
        perform(request: request, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion)
    }
    
    //MARK: - DELETE
    
    /**
     Initiates a DELETE request using the provided `DELETERequest` object
     
     This method is asynchronous, and will return control to your application immediately while processing the request
     
     - Parameter request: An `DELETERequest` object containing the information about this request
     - Parameter acceptedStatusCodes: An array of Integers defining which HTTP status codes this request should accept as valid.  Defaults to `[200 ... 299]`
     - Parameter completion: A closure that accepts an `RESTDELETEResponse` object and an Integer.  This closure will be called when all data pertaining to the request has been retrieved and processed
     - Parameter response: An `RESTDELETEResponse` object containing the retrieved object, if any.  This can be `nil`
     - Parameter statusCode: The HTTP Status Code received from the request's endpoint
     */
    public func delete<T : DELETERequest>(request: T, acceptedStatusCodes: [Int] = [200], completion: @escaping (_ response: T.Response?, _ statusCode: Int) -> Void)
    {
        let urlRequest = self.request(for: baseURL.appendingPathComponent(request.endpoint), request: request, method: .delete)
        print("DELETE \(baseURL.appendingPathComponent(request.endpoint).absoluteString)")
        perform(request: request, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion)
    }
}

//MARK: - Processing

extension RESTManager
{
    private func perform<T : RESTRequest>(request: T, urlRequest: URLRequest, withAcceptedStatusCodes acceptedStatusCodes: [Int], completion: @escaping (_ response: T.Response?, _ statusCode: Int) -> Void)
    {
        let completion : (String?) -> Void = { token in
            var urlRequest = urlRequest
            if let token = token
            {
                urlRequest.setValue(token, forHTTPHeaderField: "X-CSRFToken")
            }
            URLSession.shared.dataTask(with: urlRequest) { responseData, response, error in
                DispatchQueue.main.async {
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode else
                    {
                        self.printDebugInformation(forResponse: response, responseData: responseData, withRequest: urlRequest)
                        completion(nil, (response as? HTTPURLResponse)?.statusCode ?? 0)
                        return
                    }
                    if statusCode == 403, let data = responseData, let string = String(data: data, encoding: .utf8), string.contains("CSRF")
                    {
                        urlRequest.setValue(nil, forHTTPHeaderField: "X-CSRFToken")
                        self.csrfToken = nil
                        self.perform(request: request, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion)
                        return
                    }
                    guard acceptedStatusCodes.contains(statusCode) else
                    {
                        self.printDebugInformation(forResponse: response, responseData: responseData, withRequest: urlRequest)
                        completion(nil, statusCode)
                        return
                    }
                    if let error = error
                    {
                        print(error)
                        completion(nil, statusCode)
                        return
                    }
                    if let data = responseData
                    {
                        let parsedResponse = T.Response.fromResponse(json: (try? JSON(data: data)) ?? JSON())
                        if parsedResponse == nil
                        {
                            print("Could not interpret JSON: \((try? JSON(data: data)) ?? JSON())")
                        }
                        completion(parsedResponse, (response as? HTTPURLResponse)?.statusCode ?? -1)
                        return
                    }
                    completion(nil, statusCode)
                }
            }.resume()
        }
        if csrfToken == nil && RESTManager.requiresCSRFToken
        {
            getCSRFToken(completion: { token in
                if let token = token
                {
                    self.csrfToken = token
                }
                completion(token)
            })
        }
        else
        {
            completion(nil)
        }
    }
    
    private func perform<T : ListRequest>(request: T, urlRequest: URLRequest, withAcceptedStatusCodes acceptedStatusCodes: [Int], completion: @escaping (_ response: [T.Response]?, _ statusCode: Int) -> Void, previousResults: [T.Response]? = nil, loadAllPages: Bool = true)
    {
        func parse(results: [JSON], statusCode: Int) -> [T.Response]?
        {
            var parsedResults : [T.Response] = previousResults ?? []
            for result in results
            {
                guard let parsedResult = T.Response.fromResponse(json: result) else { return nil }
                parsedResults.append(parsedResult)
            }
            return parsedResults
        }
        let csrfCompletion : (String?) -> Void = { token in
            var urlRequest = urlRequest
            if let token = token
            {
                urlRequest.addValue(token, forHTTPHeaderField: "X-CSRFToken")
            }
            URLSession.shared.dataTask(with: urlRequest) { responseData, response, error in
                DispatchQueue.main.async {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    guard acceptedStatusCodes.contains(statusCode) else
                    {
                        self.printDebugInformation(forResponse: response, responseData: responseData, withRequest: urlRequest)
                        completion(nil, statusCode)
                        return
                    }
                    if let error = error
                    {
                        print(error)
                        completion(nil, statusCode)
                        return
                    }
                    if let data = responseData
                    {
                        let json = try! JSON(data: data)
                        guard let results = json["results"].array else
                        {
                            completion(nil, statusCode)
                            return
                        }
                        let parsedResults = parse(results: results, statusCode: statusCode)
                        if loadAllPages, let nextURLString = json["next"].string, let nextURL = URL(string: nextURLString)
                        {
                            guard let newRequest = request.requestForNextPage() else
                            {
                                completion(nil, statusCode)
                                return
                            }
                            let urlRequest = self.request(for: nextURL, request: request, method: .get)
                            self.perform(request: newRequest, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion, previousResults: parsedResults, loadAllPages: loadAllPages)
                        }
                        else
                        {
                            completion(parsedResults, statusCode)
                        }
                        return
                    }
                    completion(nil, statusCode)
                }
            }.resume()
        }
        if csrfToken == nil && RESTManager.requiresCSRFToken
        {
            getCSRFToken(completion: { token in
                if let token = token
                {
                    self.csrfToken = token
                }
                csrfCompletion(token)
            })
        }
        else
        {
            csrfCompletion(nil)
        }
    }

    private func perform<T : RESTStringRequest>(request: T, urlRequest: URLRequest, withAcceptedStatusCodes acceptedStatusCodes: [Int], completion: @escaping (_ response: T.Response?, _ statusCode: Int) -> Void)
    {
        let completion : (String?) -> Void = { token in
            var urlRequest = urlRequest
            if let token = token
            {
                urlRequest.addValue(token, forHTTPHeaderField: "X-CSRFToken")
            }
            URLSession.shared.dataTask(with: urlRequest) { responseData, response, error in
                DispatchQueue.main.async {
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, acceptedStatusCodes.contains(statusCode) else
                    {
                        self.printDebugInformation(forResponse: response, responseData: responseData, withRequest: urlRequest)
                        completion(nil, (response as? HTTPURLResponse)?.statusCode ?? 0)
                        return
                    }
                    if statusCode == 403, let data = responseData, let string = String(data: data, encoding: .utf8), string.contains("CSRF")
                    {
                        urlRequest.setValue(nil, forHTTPHeaderField: "X-CSRFToken")
                        self.csrfToken = nil
                        self.perform(request: request, urlRequest: urlRequest, withAcceptedStatusCodes: acceptedStatusCodes, completion: completion)
                        return
                    }
                    if let error = error
                    {
                        print(error)
                        completion(nil, statusCode)
                        return
                    }
                    if let data = responseData, let string = String(data: data, encoding: .utf8)
                    {
                        completion(T.Response.fromResponse(string: string), statusCode)
                        return
                    }
                    completion(nil, statusCode)
                }
                }.resume()
        }
        
        if csrfToken == nil && RESTManager.requiresCSRFToken
        {
            getCSRFToken(completion: { token in
                if let token = token
                {
                    self.csrfToken = token
                }
                completion(token)
            })
        }
        else
        {
            completion(nil)
        }
    }
}

//MARK: - CSRF

private extension RESTManager
{
    private func getCSRFToken(completion: @escaping (String?) -> Void)
    {
        get(request: CSRFRequest()) { response, statusCode in
            guard let response = response, let csrfToken = response.token.components(separatedBy: " ").dropLast().last?.components(separatedBy: "'").dropLast().last else
            {
                completion(nil)
                return
            }
            completion(csrfToken)
        }
    }
}
