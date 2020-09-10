//
//  JiraBridgePreferences.swift
//  JiraBridge
//
//  Created by Benjamin Johnson on 7/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

let userDefaultsSuiteName = "com.benjamin.jiraagent.preferences"

public enum SearchableIssuesPreference: String {
    case all
    case userAssigned
}

public enum PreferenceKey: String {
    case searchableIssues
}

public class JiraBridgePreferences {
    
    public var searchableIssues: SearchableIssuesPreference = .all
    
    public var delegate: JiraBridgePreferencesDelegate?
    
    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        
        if let searchableIssues = string(forKey: .searchableIssues),
            let searchableIssuePreference = SearchableIssuesPreference(rawValue: searchableIssues) {
            self.searchableIssues = searchableIssuePreference
        }
        
    }
    
    public convenience init() {
        self.init(userDefaults: UserDefaults(suiteName: userDefaultsSuiteName)!)
    }
    
    public func setSearchIssues(searchableIssuesPreference: SearchableIssuesPreference) {
        self.searchableIssues = searchableIssuesPreference
        self.set(searchableIssuesPreference.rawValue, forKey: .searchableIssues)
        
        didUpdatePreferences()
    }
    
    func didUpdatePreferences() {
        self.delegate?.didUpdatePreferences(preferences: self)
    }
    
    func set(_ value: String, forKey key: PreferenceKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func string(forKey key: PreferenceKey) -> String? {
        return userDefaults.string(forKey: key.rawValue)
    }
}

public protocol JiraBridgePreferencesDelegate {
    func didUpdatePreferences(preferences: JiraBridgePreferences)
}
