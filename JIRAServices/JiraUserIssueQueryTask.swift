//
//  JiraUserIssueQueryTask.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 30/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

class JiraUserIssueQueryTask {
    
    let urlSession: URLSession
    
    let baseURL: URL
    
    var issues: [JIRAIssue]?
    
    var completionHandler:((Result<[JIRAIssue], Error>) -> ())?
    
    init(urlSession: URLSession, baseURL: URL) {
        self.urlSession = urlSession
        self.baseURL = baseURL
    }
    
    func fetchIssues(completionHandler: @escaping (Result<[JIRAIssue], Error>) -> ()) {
        self.completionHandler = completionHandler
        self.issues = []
        fetchRemainingIssues(startAt: 0)
    }
    
    func fetchRemainingIssues(startAt: Int) {
        print("Fetching issues: \(startAt)")
        
        let request =  JiraUserIssueQueryRequest()
        let loader: APIRequestLoader<JiraUserIssueQueryRequest> = APIRequestLoader(apiRequest: request, urlSession: urlSession, baseURL: baseURL)
        let parameters = JiraUserIssueQueryRequestParameters(startAt: startAt)
        
        loader.loadAPIRequest(requestData: parameters, completionHandler: self.handleResponse)
    }
    
    func handleResponse(response: JiraIssueQueryResponse?, error: Error?) {
        guard let response = response else {
            self.completionHandler!(Result.failure(error!))
            return
        }
        
        self.issues = self.issues ?? [] + response.issues
        if (response.hasPendingResults) {
            self.fetchRemainingIssues(startAt: response.startAt + response.maxResults)
        } else {
            self.completionHandler!(Result.success(self.issues!))
        }
    }
}
