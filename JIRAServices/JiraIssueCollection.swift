//
//  JiraIssueCollection.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 23/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

struct JiraIssueCollection: Decodable {
    let total: Int
    let startAt: Int
    let issues: [JIRAIssue]
}
