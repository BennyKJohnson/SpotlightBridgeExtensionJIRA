//
//  JiraIssueSuggestionResponse.swift
//  JiraAgent
//
//  Created by Benjamin Johnson on 9/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation


struct JiraIssueSuggestionResponse: Decodable {
    
    let sections: [JiraIssueSuggestionSection]
    
    var historySearch: JiraIssueSuggestionSection? {
        get {
            return self.findSection(id: "hs")
        }
    }
    
    var currentSearch: JiraIssueSuggestionSection? {
        get {
            return self.findSection(id: "cs")
        }
    }
    
    func findSection(id: String) -> JiraIssueSuggestionSection? {
        return sections.first(where: { (section) -> Bool in
            return section.id == id
        })
    }
    
}

struct JiraIssueSuggestionSection: Decodable {
    
    let label: String
    
    let id: String
    
    let issues: [JiraIssueSuggestion]
    
}

struct JiraIssueSuggestion: Decodable {
    
    let id: Int
    
    let key: String
    
    let summary: String
    
}
