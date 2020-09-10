//
//  JiraUserIssueQueryTask.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 30/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JiraKit

class JiraUserIssueQueryTask {
    
    let urlSession: URLSession
    
    let baseURL: URL
    
    var issues: [JIRAIssue]?
    
    var completionHandler:((Result<[JIRAIssue], Error>) -> ())?
    
    let onlyUserAssignee: Bool
    
    var maxResults: Int?
    
    var issueKey: String?
    
    var query: String?
    
    var apiLoader: APIRequestLoader<JiraUserIssueQueryRequest>?
    
    init(urlSession: URLSession, baseURL: URL, onlyUserAssignee: Bool = false) {
        self.urlSession = urlSession
        self.baseURL = baseURL
        self.onlyUserAssignee = onlyUserAssignee
    }
    
    func fetchIssues(completionHandler: @escaping (Result<[JIRAIssue], Error>) -> ()) {
        self.completionHandler = completionHandler
        self.issues = []
        
        let requestParameters = makeRequestParameters(startAt: 0)
        fetchRemainingIssues(requestParameters: requestParameters)
    }
    
    func makeRequestParameters(startAt: Int) -> JiraUserIssueQueryRequestParameters {
        var parameters = JiraUserIssueQueryRequestParameters(startAt: startAt, onlyUserAssignee: onlyUserAssignee)
        parameters.maxResults = maxResults
        parameters.query = query
        
        return parameters
    }
    
    func cancel() {
        self.apiLoader?.cancel()
    }
    
    func fetchRemainingIssues(requestParameters: JiraUserIssueQueryRequestParameters) {
        let request =  JiraUserIssueQueryRequest()
        let loader: APIRequestLoader<JiraUserIssueQueryRequest> = APIRequestLoader(apiRequest: request, urlSession: urlSession, baseURL: baseURL)
        self.apiLoader = loader
        
        loader.loadAPIRequest(requestData: requestParameters, completionHandler: self.handleResponse)
    }
    
    func handleResponse(response: JiraIssueQueryResponse?, error: Error?) {
        guard let response = response else {
            self.completionHandler!(Result.failure(error!))
            return
        }
        
        self.issues = self.issues! + response.issues
        if (response.hasPendingResults) {
            let startAt = response.startAt + response.maxResults
            let requestParameters = makeRequestParameters(startAt: startAt)
            self.fetchRemainingIssues(requestParameters: requestParameters)
        } else {
            self.completionHandler!(Result.success(self.issues!))
        }
    }
}
