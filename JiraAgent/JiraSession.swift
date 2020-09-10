//
//  JiraSession.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 23/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JiraKit

public class JiraSession: NSObject {
    
    let configuration: JiraSessionConfiguration
    
    let urlSession: URLSession
    
    let userIssueQueryRequest: JiraUserIssueQueryRequest
        
    var issueSuggestionQueryTask: JiraIssueSuggestionQueryTask?
    
    public init(configuration: JiraSessionConfiguration) {
        self.configuration = configuration
        let urlSessionConfigration = JiraSession.urlSessionConfiguration(for: configuration)
        self.urlSession = URLSession(configuration: urlSessionConfigration)
        userIssueQueryRequest = JiraUserIssueQueryRequest()
    }
    
    class func urlSessionConfiguration(for configuration: JiraSessionConfiguration) -> URLSessionConfiguration {
        let urlSessionConfiguration = URLSessionConfiguration.default
        let authenication = String(format: "%@:%@", configuration.username, configuration.password)
        let authenicationDataBase64 = authenication.data(using: .utf8)!.base64EncodedString()
        urlSessionConfiguration.httpAdditionalHeaders = ["Authorization": "Basic \(authenicationDataBase64)"]

        return urlSessionConfiguration
    }
    
    public func fetchIssues(onlyUserAssignee: Bool, completionHandler: @escaping ((Result<[JIRAIssue], Error>) -> ())) {
        let userIssueQueryTask = JiraUserIssueQueryTask(urlSession: self.urlSession, baseURL: baseURL, onlyUserAssignee: onlyUserAssignee)
        userIssueQueryTask.fetchIssues(completionHandler: completionHandler)
    }
    
    public func queryIssueSuggestions(query: String,  completionHandler: @escaping ((Result<[JIRAIssue], Error>) -> ())) {
        if let issueSuggestionQueryTask = issueSuggestionQueryTask {
            issueSuggestionQueryTask.cancel()
        }
        
        let issueSuggestionQueryTask = JiraIssueSuggestionQueryTask(urlSession: self.urlSession, baseURL: baseURL)
        self.issueSuggestionQueryTask = issueSuggestionQueryTask
        
        issueSuggestionQueryTask.fetchIssueSuggestions(query: query, completionHandler: completionHandler);
    }
    
    public func fetchIssueDetails(issueKey: String, completionHandler: @escaping (Result<JIRAIssue, Error>) -> ()) {
        let fetchIssueTask = JiraUserIssueQueryTask(urlSession: self.urlSession, baseURL: baseURL, onlyUserAssignee: false)
        fetchIssueTask.query = issueKey
        
        fetchIssueTask.fetchIssues { (result) in
            switch result {
            case .failure(let failure):
                completionHandler(Result.failure(failure))
            case .success(let results):
                let result = results[0]
                completionHandler(Result.success(result))
            }
        }
    }

    var baseURL: URL {
        get {
            return configuration.siteURL
                .appendingPathComponent("/rest/api")
                .appendingPathComponent(configuration.apiVersion)
        }
    }
}
