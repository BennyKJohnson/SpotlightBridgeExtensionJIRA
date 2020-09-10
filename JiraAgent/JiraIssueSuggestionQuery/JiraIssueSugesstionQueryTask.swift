//
//  JiraIssueSugesstionQueryTask.swift
//  JiraAgent
//
//  Created by Benjamin Johnson on 9/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JiraKit

class JiraIssueSuggestionQueryTask {
    
    var apiLoader: APIRequestLoader<JiraIssueSuggestionQueryRequest>?
    
    var completionHandler: ((Result<[JIRAIssue], Error>) -> ())?
    
    let urlSession: URLSession
    
    let baseURL: URL
    
    init(urlSession: URLSession, baseURL: URL) {
        self.urlSession = urlSession
        self.baseURL = baseURL
    }
    
    func fetchIssueSuggestions(query: String, completionHandler: @escaping (Result<[JIRAIssue], Error>) -> ()) {
        self.completionHandler = completionHandler
        
        let requestParameters = JiraIssueSuggestionQueryRequestParameters(query: query)
        let request = JiraIssueSuggestionQueryRequest()
        let loader = APIRequestLoader(apiRequest: request, urlSession: urlSession, baseURL: baseURL)
        self.apiLoader = loader
        
        loader.loadAPIRequest(requestData: requestParameters, completionHandler: self.handleResponse)
    }
    
    func handleResponse(response: JiraIssueSuggestionResponse?, error: Error?) {
        guard let response = response else {
            self.completionHandler!(Result.failure(error!))
            return
        }
        
        guard let currentSearch = response.currentSearch else {
           fatalError("Current search not found in suggestions")
        }
        
        let issues = currentSearch.issues.map(self.suggestionToIssue)
        
        completionHandler!(Result.success(issues))
    }
    
    func suggestionToIssue(suggestion: JiraIssueSuggestion) -> JIRAIssue {
         return JIRAIssue(key: suggestion.key, title: suggestion.summary, description: nil, timeSpent: nil)
    }
    
    func cancel() {
        apiLoader?.cancel()
    }
}
