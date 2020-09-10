//
//  JiraUserIssueQueryRequest.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 30/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

struct JiraUserIssueQueryRequestParameters {
    let startAt: Int
    let onlyUserAssignee: Bool
    var maxResults: Int?
    var query: String?
    
    init(startAt: Int, onlyUserAssignee: Bool) {
        self.startAt = startAt
        self.onlyUserAssignee = onlyUserAssignee
    }
}

struct JiraUserIssueQueryRequest: APIRequest {

    typealias RequestDataType = JiraUserIssueQueryRequestParameters
    
    typealias ResponseDataType = JiraIssueQueryResponse
    
    typealias ResponseErrorDataType = JiraErrorMessage
    
    func makeRequest(baseURL: URL, from data: JiraUserIssueQueryRequestParameters) -> URLRequest {
        var urlCompounts = URLComponents(url: baseURL.appendingPathComponent("search"), resolvingAgainstBaseURL: false)!
        var queryItems = [
            URLQueryItem(name: "startAt", value: "\(data.startAt)")
        ]
        
        if let maxResults = data.maxResults {
            queryItems.append(URLQueryItem(name: "maxResults", value: "\(maxResults)"))
        }
        
        var jqlComponents: [String] = []
        if data.onlyUserAssignee {
            jqlComponents.append("assignee=currentUser()")
        }
        
        if let query = data.query {
            jqlComponents.append("issuekey=\(query)")
        }
        
        if (jqlComponents.count > 0) {
            let jqlQueryString = jqlComponents.joined(separator: " AND ")
            queryItems.append(URLQueryItem(name: "jql", value: jqlQueryString))
        }
        
        urlCompounts.queryItems = queryItems
        
        let url = urlCompounts.url!
        
        return URLRequest(url: url)
    }
    
    func parseResponse(data: Data) throws -> JiraIssueQueryResponse {
        return try JSONDecoder().decode(JiraIssueQueryResponse.self, from: data)
    }
    
    func parseErrorResponse(data: Data) throws -> JiraErrorMessage {
        return try JSONDecoder().decode(JiraErrorMessage.self, from: data)
    }
}

