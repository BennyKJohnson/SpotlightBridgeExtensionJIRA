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
    
    public var status: String?
    
    public init(key: String, title: String, description: String?, timeSpent: TimeInterval?, domain: String? = nil) {
        self.key = key
        self.title = title
        self.issueDescription = description
        self.timeSpent = timeSpent
        self.domain = domain
    }
    
    public init(identifier: String, key: String, title: String, description: String?, timeSpent: TimeInterval?, domain: String?) {
        self.identifier = identifier
        self.key = key
        self.title = title
        self.issueDescription = description
        self.timeSpent = timeSpent
        self.domain = domain
    }
    
    public var url: URL? {
        get {
            guard let domain = domain else {
                return nil
            }
            
            return URL(string: "https://\(domain)/browse/\(key)")
        }
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
        case status
    }
    
    enum StatusJSONJeys: String, CodingKey {
        case name
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
        
        let selfUrl = try root.decode(URL.self, forKey: .selfUrl)
        let selfUrlComponents = URLComponents(url: selfUrl, resolvingAgainstBaseURL: false)
        let domain = selfUrlComponents?.host
        
        self.init(key: key, title: title, description: description, timeSpent: timeSpent, domain: domain)
        
        if (fields.contains(.status)) {
            let statusContainer = try fields.nestedContainer(keyedBy: StatusJSONJeys.self, forKey: .status)
            let status = try statusContainer.decodeIfPresent(String.self, forKey: .name)
            self.status = status
        }
        
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
        case domain
        case status
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(key, forKey: .key)
        try container.encode(issueDescription, forKey: .issueDescription)
        try container.encode(timeSpent, forKey: .timeSpent)
        try container.encode(domain, forKey: .domain)
        try container.encode(status, forKey: .status)
        
        if let assignee = self.assignee {
            try container.encode(assignee, forKey: .assignee)
        }
    }
    
    convenience init(internalDecoder decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: InternalCodingKeys.self)
        
        let title = try root.decode(String.self, forKey: .title)
        let description = try root.decodeIfPresent(String.self, forKey: .issueDescription)
        let timeSpent = try root.decodeIfPresent(TimeInterval.self, forKey: .timeSpent)
        let key = try root.decode(String.self, forKey: .key)
        let domain = try root.decodeIfPresent(String.self, forKey: .domain)
        self.init(key: key, title: title, description: description, timeSpent: timeSpent, domain: domain)
        
        let assignee = try root.decodeIfPresent(JiraAssignee.self, forKey: .assignee)
        self.assignee = assignee
        
        let status = try root.decodeIfPresent(String.self, forKey: .status)
        self.status = status
    }
}
