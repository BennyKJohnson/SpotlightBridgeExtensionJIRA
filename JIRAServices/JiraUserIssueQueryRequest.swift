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
}

struct JiraUserIssueQueryRequest: APIRequest {

    typealias RequestDataType = JiraUserIssueQueryRequestParameters
    
    typealias ResponseDataType = JiraIssueQueryResponse
    
    func makeRequest(baseURL: URL, from data: JiraUserIssueQueryRequestParameters) -> URLRequest {
        var urlCompounts = URLComponents(url: baseURL.appendingPathComponent("search"), resolvingAgainstBaseURL: false)!
        urlCompounts.queryItems = [
            URLQueryItem(name: "jql", value: "assignee=currentUser()"),
            URLQueryItem(name: "startAt", value: "\(data.startAt)")
        ]
        
        let url = urlCompounts.url!
        return URLRequest(url: url)
    }
    
    func parseResponse(data: Data) throws -> JiraIssueQueryResponse {
        return try JSONDecoder().decode(JiraIssueQueryResponse.self, from: data)
    }
}
