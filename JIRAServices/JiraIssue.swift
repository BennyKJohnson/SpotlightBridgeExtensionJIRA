//
//  JIRAIssue.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 13/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Cocoa

public struct JIRAIssue: Decodable {
    public let key: String
    public let title: String
    public let description: String?
    public let timeSpent: TimeInterval?
    public let domain: String?
    
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
    
    public init(key: String, title: String, description: String?, loggedTime: String?) {
        self.key = key
        self.title = title
        self.description = description
        self.timeSpent = nil
        self.domain = nil
    }
}
