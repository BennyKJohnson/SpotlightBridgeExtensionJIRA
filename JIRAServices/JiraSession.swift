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
    
    public init(configuration: JiraSessionConfiguration) {
        self.configuration = configuration
        let urlSessionConfigration = JiraSession.urlSessionConfiguration(for: configuration)
        self.urlSession = URLSession(configuration: urlSessionConfigration)
    }
    
    class func urlSessionConfiguration(for configuration: JiraSessionConfiguration) -> URLSessionConfiguration {
        let urlSessionConfiguration = URLSessionConfiguration.default
        let authenication = String(format: "%@:%@", configuration.username, configuration.password)
        let authenicationDataBase64 = authenication.data(using: .utf8)!.base64EncodedString()
        urlSessionConfiguration.httpAdditionalHeaders = ["Authorization": "Basic \(authenicationDataBase64)"]

        return urlSessionConfiguration
    }
    
    public func fetchIssues(completionHandler: @escaping (_ issues: [JIRAIssue]) -> ()) {
        var urlCompounts = URLComponents(url: url(withPath: "search"), resolvingAgainstBaseURL: false)!
        urlCompounts.queryItems = [
            URLQueryItem(name: "jql", value: "assignee=currentUser()")
        ]
        
        let task = urlSession.dataTask(with: urlCompounts.url!) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            let issueCollection = try! decoder.decode(JiraIssueCollection.self, from: data)
            completionHandler(issueCollection.issues)
        }
        
        task.resume()
    }
    
    func url(withPath path: String) -> URL {
        return configuration.siteURL
            .appendingPathComponent("/rest/api")
            .appendingPathComponent(configuration.apiVersion)
            .appendingPathComponent(path)
    }
}
