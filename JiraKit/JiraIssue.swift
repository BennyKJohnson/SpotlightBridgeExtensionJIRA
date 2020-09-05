//
//  JIRAIssue.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 13/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

@objc public final class JIRAIssue: NSObject, Codable {
    
    public let key: String
    
    public let title: String
    
    public let issueDescription: String?
    
    public let timeSpent: TimeInterval?
    
    public let domain: String?
    
    public var assignee: JiraAssignee?
    
    public var identifier: String?
    
    public var issueID: String {
        get {
            return key.components(separatedBy: "-")[1]
        }
    }
    
    public init(key: String, title: String, description: String?, timeSpent: TimeInterval?) {
        self.key = key
        self.title = title
        self.issueDescription = description
        self.timeSpent = timeSpent
        self.domain = nil
    }
    
    public init(identifier: String, key: String, title: String, description: String?, timeSpent: TimeInterval?) {
        self.identifier = identifier
        self.key = key
        self.title = title
        self.issueDescription = description
        self.timeSpent = timeSpent
        self.domain = nil
    }
}



extension JIRAIssue {
    enum JSONKeys: String, CodingKey {
        case title = "summary"
        case key = "key"
        case fields = "fields"
        case timeSpent = "timespent"
        case selfUrl = "self"
        case assigneeDisplayName = "displayName"
        case assignee = "assignee"
        case description = "description"
        case avatarUrls = "avatarUrls"
        case largeAvatar = "48x48"
    }
    
    public convenience init(from decoder: Decoder) throws {
        if decoder.context?.isUsingInternalKeys ?? false {
            try self.init(internalDecoder: decoder)
        } else {
            try self.init(jsonDecoder: decoder)
        }
    }
    
    convenience init(jsonDecoder decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: JSONKeys.self)
        
        let key = try root.decode(String.self, forKey: .key)
        let fields = try root.nestedContainer(keyedBy: JSONKeys.self, forKey: .fields)
        let title = try fields.decode(String.self, forKey: .title)
        let timeSpent = try fields.decodeIfPresent(TimeInterval.self, forKey: .timeSpent)
        let description = try fields.decodeIfPresent(String.self, forKey: .description)
        
        self.init(key: key, title: title, description: description, timeSpent: timeSpent)
        
        if (fields.contains(.assignee)) {
            let assigneeContainer = try fields.nestedContainer(keyedBy: JSONKeys.self, forKey: .assignee)
            let name = try assigneeContainer.decodeIfPresent(String.self, forKey: .assigneeDisplayName)
            if let name = name {
                var avatarUrl: URL?
                if (assigneeContainer.contains(.avatarUrls)) {
                    avatarUrl = try assigneeContainer.nestedContainer(keyedBy: JSONKeys.self, forKey: .avatarUrls) .decodeIfPresent(URL.self, forKey: .largeAvatar)
                }
                
                self.assignee =  JiraAssignee(name: name, avatarURL: avatarUrl)
            }
        }
    }
}

extension JIRAIssue {
    enum InternalCodingKeys: String, CodingKey {
        case title
        case key
        case issueDescription
        case timeSpent
        case assignee
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(key, forKey: .key)
        try container.encode(issueDescription, forKey: .issueDescription)
        try container.encode(timeSpent, forKey: .timeSpent)
        
        if let assignee = self.assignee {
            try container.encode(assignee, forKey: .assignee)
        }
    }
    
    convenience init(internalDecoder decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: InternalCodingKeys.self)
        
        let title = try root.decode(String.self, forKey: .title)
        let description = try root.decodeIfPresent(String.self, forKey: .issueDescription)
        let timeSpent = try root.decode(TimeInterval.self, forKey: .timeSpent)
        let key = try root.decode(String.self, forKey: .key)
        
        self.init(key: key, title: title, description: description, timeSpent: timeSpent)
        
        let assignee = try root.decodeIfPresent(JiraAssignee.self, forKey: .assignee)
        self.assignee = assignee
    }
}
