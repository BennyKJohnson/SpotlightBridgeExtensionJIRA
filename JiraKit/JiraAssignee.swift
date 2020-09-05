//
//  JiraAssignee.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 1/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

public struct JiraAssignee: Codable {
    
    public let name: String
    
    public let avatarURL: URL?
    
    public init(name: String, avatarURL: URL?) {
        self.name = name
        self.avatarURL = avatarURL
    }
    
}
