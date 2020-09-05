//
//  Decodable+Context.swift
//  JiraKit
//
//  Created by Benjamin Johnson on 5/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

public struct DecodingContext {
    public let isUsingInternalKeys: Bool = true
    
    public init() {}
}

private let contextKey = CodingUserInfoKey(rawValue: "context")!

extension JSONDecoder {
    public var context: DecodingContext? {
        get { return userInfo[contextKey] as? DecodingContext }
        set { userInfo[contextKey] = newValue }
    }
}

extension Decoder {
    public var context: DecodingContext? {
        return userInfo[contextKey] as? DecodingContext
    }
}
