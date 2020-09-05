//
//  JiraServiceProtocol.swift
//  JiraAgent
//
//  Created by Benjamin Johnson on 3/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

@objc public protocol JiraServiceProtocol {

    func queryIssues(userQueryString: String, completionHandler: @escaping ([Data]?, Error?) -> ())

}
