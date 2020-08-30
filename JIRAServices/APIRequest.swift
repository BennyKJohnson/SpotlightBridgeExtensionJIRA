//
//  APIRequest.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 30/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

protocol APIRequest {
    associatedtype RequestDataType
    associatedtype ResponseDataType
    
    func makeRequest(baseURL: URL, from data: RequestDataType) throws -> URLRequest
    func parseResponse(data: Data) throws -> ResponseDataType
}

class APIRequestLoader<T: APIRequest> {
    
    let apiRequest: T
    
    let urlSession: URLSession
    
    let baseURL: URL
    
    var completionHandler:  ((T.ResponseDataType?, Error?) -> ())!
    
    init(apiRequest: T, urlSession: URLSession, baseURL: URL) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
        self.baseURL = baseURL
    }
    
    func loadAPIRequest(requestData: T.RequestDataType, completionHandler: @escaping (T.ResponseDataType?, Error?) -> Void) {
        self.completionHandler = completionHandler
        
        do {
            let urlRequest = try apiRequest.makeRequest(baseURL: baseURL, from: requestData)
            let dataTask = urlSession.dataTask(with: urlRequest, completionHandler: self.handleAPIResponse)
            dataTask.resume()
        } catch {
            return completionHandler(nil, error)
        }
    }
    
    func handleAPIResponse(data: Data?, response: URLResponse?, error: Error?) {
        guard let data = data else { return completionHandler(nil, error) }
        do {
            let parsedResponse = try self.apiRequest.parseResponse(data: data)
            completionHandler(parsedResponse, nil)
        } catch {
            completionHandler(nil, error)
        }
    }
    
}
