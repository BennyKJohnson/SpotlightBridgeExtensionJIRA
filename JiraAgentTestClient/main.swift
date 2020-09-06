//
//  main.swift
//  JiraAgentTestClient
//
//  Created by Benjamin Johnson on 6/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JiraKit

let connection = NSXPCConnection(machServiceName: "com.benjamin.jiraagentXPC", options: [])
connection.remoteObjectInterface = NSXPCInterface(with: JiraServiceProtocol.self)
connection.resume()

let service = connection.remoteObjectProxyWithErrorHandler { (error) in
    print("Connection error")
    print(error)
    } as? JiraServiceProtocol


service!.queryIssues(userQueryString: "SPARK", completionHandler: { (results, error) in
    if let results = results {
        
        let decoder = JSONDecoder()
        decoder.context = DecodingContext()
        
        let issues = results.map({(issueData) in
            return   try! decoder.decode(JIRAIssue.self, from: issueData)
        })
        
        let issueTitles = issues.map({ (issue) -> String in
            return issue.title
        })
        
        print(issueTitles)
        
    } else {
        print(error)
    }
})

print("Looks good")
RunLoop.current.run()


