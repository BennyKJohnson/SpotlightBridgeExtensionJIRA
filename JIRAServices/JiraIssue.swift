//
//  JIRAIssue.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 13/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

public struct JIRAIssue: ObjectConvertible {
    public let key: String
    public let title: String
    public let description: String?
    public let timeSpent: TimeInterval?
    public let domain: String?
    
    private(set) var identifier: String?
    
    public var issueID: String {
        get {
            return key.components(separatedBy: "-")[1]
        }
    }
    
    public init(key: String, title: String, description: String?, timeSpent: TimeInterval?) {
        self.key = key
        self.title = title
        self.description = description
        self.timeSpent = timeSpent
        self.domain = nil
    }
    
    public init(identifier: String, key: String, title: String, description: String?, timeSpent: TimeInterval?) {
        self.identifier = identifier
        self.key = key
        self.title = title
        self.description = description
        self.timeSpent = timeSpent
        self.domain = nil
    }
}

extension JIRAIssue: Decodable {
    enum CodingKeys: String, CodingKey {
        case title = "summary"
        case key = "key"
        case fields = "fields"
        case timeSpent = "timespent"
        case selfUrl = "self"
    }
    
    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        key = try root.decode(String.self, forKey: .key)
        
        let selfUrl = try root.decode(URL.self, forKey: .selfUrl)
        let selfUrlComponents = URLComponents(url: selfUrl, resolvingAgainstBaseURL: false)
        domain = selfUrlComponents?.host
        
        let fields = try root.nestedContainer(keyedBy: CodingKeys.self, forKey: .fields)
        title = try fields.decode(String.self, forKey: .title)
        timeSpent = try fields.decodeIfPresent(TimeInterval.self, forKey: .timeSpent)
        
        description = nil
    }
}
