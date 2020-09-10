//
//  APIRequest.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 30/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import os

protocol APIRequest {
    
    associatedtype RequestDataType
    
    associatedtype ResponseDataType
    
    associatedtype ResponseErrorDataType: Error
    
    func makeRequest(baseURL: URL, from data: RequestDataType) throws -> URLRequest
    
    func parseResponse(data: Data) throws -> ResponseDataType
    
    func parseErrorResponse(data: Data) throws -> ResponseErrorDataType
    
}

class APIRequestLoader<T: APIRequest> {
    
    let apiRequest: T
    
    let urlSession: URLSession
    
    let baseURL: URL
    
    var completionHandler:  ((T.ResponseDataType?, Error?) -> ())!
    
    var dataTask: URLSessionDataTask?
    
    init(apiRequest: T, urlSession: URLSession, baseURL: URL) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
        self.baseURL = baseURL
    }
    
    func loadAPIRequest(requestData: T.RequestDataType, completionHandler: @escaping (T.ResponseDataType?, Error?) -> Void) {
        self.completionHandler = completionHandler
        
        do {
            let urlRequest = try apiRequest.makeRequest(baseURL: baseURL, from: requestData)
            os_log("Requesting %{public}s", urlRequest.url!.absoluteString)
            let dataTask = urlSession.dataTask(with: urlRequest, completionHandler: self.handleAPIResponse)
            self.dataTask = dataTask
            
            dataTask.resume()
        } catch {
            completionHandler(nil, error)
        }
    }
    
    func handleAPIResponse(data: Data?, response: URLResponse?, error: Error?) {
        guard let data = data else { return completionHandler(nil, error) }
        do {
            let parsedResponse = try self.apiRequest.parseResponse(data: data)
            completionHandler(parsedResponse, nil)
        } catch {
            if let errorMessage = try? self.apiRequest.parseErrorResponse(data: data) {
                completionHandler(nil, errorMessage)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    func cancel() {
        self.dataTask?.cancel()
    }
}
