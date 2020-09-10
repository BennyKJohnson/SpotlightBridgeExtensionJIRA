//
//  JiraStoreTests.swift
//  JIRAServicesTests
//
//  Created by Benjamin Johnson on 28/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import XCTest
@testable import JiraKit

class JiraStoreTests: XCTestCase {
    
    var dataStore: JiraStore!
    var mockPersistantContainer: NSPersistentContainer!
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        coreDataManager = CoreDataManager.shared
        mockPersistantContainer = coreDataManager.mockPersistantContainer
        
        dataStore = JiraStore(container: coreDataManager.mockPersistantContainer)
    }

    override func tearDown() {
        flushData()
    }

    func testInit() {
        let jiraDataStore = JiraStore(container: mockPersistantContainer)
        XCTAssertNotNil(jiraDataStore)
        XCTAssertEqual(jiraDataStore.context, mockPersistantContainer.viewContext)
    }
    
    func testInsertJiraIssue() {
        let issue = JIRAIssue(key: "ABC-123", title: "My issue", description: nil, timeSpent: nil, domain: nil)
        dataStore.insert(issue)

        let request: NSFetchRequest<JiraIssueManagedObject> = JiraIssueManagedObject.fetchRequest()
        let results = try! mockPersistantContainer.viewContext.fetch(request)
        XCTAssertEqual(results.count, 1)
        let result = results[0]

        XCTAssertEqual(result.key, "ABC-123")
    }
    
    func testDeleteJiraIssue() {
        let issueToDelete = JIRAIssue(key: "DELETE-1", title: "Issue to delete", description: nil, timeSpent: nil, domain: nil)
        dataStore.insert(issueToDelete)
        
        let request: NSFetchRequest<JiraIssueManagedObject> = JiraIssueManagedObject.fetchRequest()
        let results = try! mockPersistantContainer.viewContext.fetch(request)
        XCTAssertEqual(results.count, 1)
        
        let createdIssue = results[0].toObject()
        dataStore.delete(createdIssue)
        
        let resultsAfterDeletion = try! mockPersistantContainer.viewContext.fetch(request)
        XCTAssertEqual(resultsAfterDeletion.count, 0)
    }
    
    func testUpdateJiraIssue() {
        let issue = JIRAIssue(key: "ABC-123", title: "My issue", description: nil, timeSpent: nil, domain: nil)
        let insertedIssue = dataStore.insert(issue)
        
        let updatedIssue = JIRAIssue(identifier: insertedIssue!.identifier!, key: "ABC-123", title: "Updated issue title", description: nil, timeSpent: nil, domain: nil)
        
        dataStore.update(updatedIssue)
        
        let request: NSFetchRequest<JiraIssueManagedObject> = JiraIssueManagedObject.fetchRequest()
        let resultsAfterUpdate = try! mockPersistantContainer.viewContext.fetch(request)
      
        let issueAfterUpdate = resultsAfterUpdate[0].toObject()
        XCTAssertEqual(issueAfterUpdate.title, "Updated issue title")
    }
    
    func testJiraIssueFetchAll() {
        let issue = jiraIssue(key: "1")
        let secondIssue = jiraIssue(key: "2")
        
        dataStore.insert(issue)
        dataStore.insert(secondIssue)

        let issues = dataStore.fetchAll()
        XCTAssertEqual(issues.count, 2)
        
        XCTAssertTrue(containsIssue(issue: issue, issues: issues))
        XCTAssertTrue(containsIssue(issue: secondIssue, issues: issues))
    }
    
    func testFetch() {
        let issueWithMatchingTitle = JIRAIssue(key: "1", title: "My issue", description: nil, timeSpent: nil, domain: nil)
        let issueWithMatchingTitle2 = JIRAIssue(key: "2", title: "My issue", description: nil, timeSpent: nil, domain: nil)
        let issueWithoutMatchingTitle = JIRAIssue(key: "3", title: "Another title", description: nil, timeSpent: nil, domain: nil)
        
        dataStore.insert(issueWithMatchingTitle)
        dataStore.insert(issueWithMatchingTitle2)
        dataStore.insert(issueWithoutMatchingTitle)
        
        let predicate = NSPredicate(format: "summary = %@", "My issue")
        let results  = try! dataStore.fetch(predicate: predicate)
        
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(containsIssue(issue: issueWithMatchingTitle, issues: results))
        XCTAssertTrue(containsIssue(issue: issueWithMatchingTitle2, issues: results))
    }
    
    func testFetchWithSortDescriptor() {
        let issueWithMatchingTitle = JIRAIssue(key: "Key-1", title: "My issue", description: nil, timeSpent: nil, domain: nil)
        let issueWithMatchingTitle2 = JIRAIssue(key: "Key-2", title: "My issue", description: nil, timeSpent: nil, domain: nil)
        let issueWithMatchingTitle3 = JIRAIssue(key: "Key-3", title: "My issue", description: nil, timeSpent: nil, domain: nil)
        
        dataStore.insert(issueWithMatchingTitle3)
        dataStore.insert(issueWithMatchingTitle2)
        dataStore.insert(issueWithMatchingTitle)
        
        let predicate = NSPredicate(format: "summary = %@", "My issue")
        let results  = try! dataStore.fetch(predicate: predicate, sortDescriptors: [NSSortDescriptor(key: "key", ascending: true)])
        
        XCTAssertEqual(results[0].key, "Key-1")
        XCTAssertEqual(results[1].key, "Key-2")
        XCTAssertEqual(results[2].key, "Key-3")

    }
    
    func testFindJiraIssue() {
        let issue = jiraIssue(key: "APP-123")
        dataStore.insert(issue)
        
        let foundIssue = dataStore.findIssue(key: "APP-123")
        XCTAssertNotNil(foundIssue)
        XCTAssertEqual(foundIssue!.key, "APP-123")
        
        XCTAssertNil(dataStore.findIssue(key: "BOGUS"))
    }
    
    func containsIssue(issue: JIRAIssue, issues: [JIRAIssue]) -> Bool {
        return issues.first(where: { (aIssue) -> Bool in
            aIssue.key == issue.key
        }) != nil
    }
    
    func jiraIssue(key: String) -> JIRAIssue {
        return JIRAIssue(key: key, title: "My issue", description: nil, timeSpent: nil, domain: nil)
    }
    
    func flushData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = JiraIssueManagedObject.fetchRequest()
        let results = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
        for case let result as NSManagedObject in results {
            mockPersistantContainer.viewContext.delete(result)
        }
        
        try! mockPersistantContainer.viewContext.save()
    }
}
