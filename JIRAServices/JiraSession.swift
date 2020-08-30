//
//  JiraSession.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 23/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

public class JiraSession: NSObject {
    
    let configuration: JiraSessionConfiguration
    
    let urlSession: URLSession
    
    let userIssueQueryRequest: JiraUserIssueQueryRequest
    
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
    
    public func fetchIssues(completionHandler: @escaping ((Result<[JIRAIssue], Error>) -> ())) {
        let userIssueQueryTask = JiraUserIssueQueryTask(urlSession: self.urlSession, baseURL: baseURL)
        userIssueQueryTask.fetchIssues(completionHandler: completionHandler)
    }

    var baseURL: URL {
        get {
            return configuration.siteURL
                .appendingPathComponent("/rest/api")
                .appendingPathComponent(configuration.apiVersion)
        }
    }

    func url(withPath path: String) -> URL {
        return baseURL.appendingPathComponent(path)
    }
}
