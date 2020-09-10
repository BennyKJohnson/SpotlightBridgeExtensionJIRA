//
//  JiraIssueSuggestionQuery.swift
//  JiraAgent
//
//  Created by Benjamin Johnson on 8/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation


struct JiraIssueSuggestionQueryRequestParameters {
    
    let query: String
}

struct JiraIssueSuggestionQueryRequest: APIRequest {

    typealias RequestDataType = JiraIssueSuggestionQueryRequestParameters
    
    typealias ResponseDataType = JiraIssueSuggestionResponse
    
    typealias ResponseErrorDataType = JiraErrorMessage
    
    func makeRequest(baseURL: URL, from data: JiraIssueSuggestionQueryRequestParameters) -> URLRequest {
        let url = baseURL.appendingPathComponent("issue").appendingPathComponent("picker")
        
        var urlCompounts = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = [
            URLQueryItem(name: "query", value: data.query),
            URLQueryItem(name: "currentJQL", value: nil)
        ]
        
        urlCompounts.queryItems = queryItems
        
        return URLRequest(url: urlCompounts.url!)
    }
    
    func parseResponse(data: Data) throws -> JiraIssueSuggestionResponse {
        return try JSONDecoder().decode(JiraIssueSuggestionResponse.self, from: data)
    }
    
    func parseErrorResponse(data: Data) throws -> JiraErrorMessage {
        return try JSONDecoder().decode(JiraErrorMessage.self, from: data)
    }
}

