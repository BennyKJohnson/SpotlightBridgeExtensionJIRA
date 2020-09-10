//
//  JiraIssueCollection.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 23/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JiraKit

struct JiraIssueQueryResponse: Decodable {
    
    let total: Int
    
    let startAt: Int
    
    let maxResults: Int
    
    let issues: [JIRAIssue]
    
    var hasPendingResults: Bool {
        get {
               return self.startAt + self.maxResults < self.total
        }
    }
}

struct JiraErrorMessage: Decodable, Error {
    
    let errorMessages: [String]
    
    let warningMessages: [String]
    
}
