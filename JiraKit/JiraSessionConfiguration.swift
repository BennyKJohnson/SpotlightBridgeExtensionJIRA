//
//  JiraSessionConfiguration.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 23/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

public struct JiraSessionConfiguration: Equatable {
    public let siteURL: URL
    public let username: String
    public let password: String
    public let apiVersion: String = "latest"
    
    public static func fromFile(for url: URL) -> JiraSessionConfiguration? {
        guard let jsonData = try? Data(contentsOf: url) else {
            return nil
        }

        let decoder = JSONDecoder()
        let configuration = try? decoder.decode(JiraSessionConfiguration.self, from: jsonData)
        return configuration
    }
}

extension JiraSessionConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case siteURL = "domain"
        case username
        case password = "authToken"
    }
    
    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.siteURL = try root.decode(URL.self, forKey: .siteURL)
        self.username = try root.decode(String.self, forKey: .username)
        self.password = try root.decode(String.self, forKey: .password)
    }
}
