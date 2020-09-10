//
//  JiraBridgePreferencesViewController.swift
//  JiraBridge
//
//  Created by Benjamin Johnson on 7/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Cocoa
import JiraKit

class JiraBridgePreferencesViewController: NSViewController {
    
    @IBOutlet weak var issueResultsPreferenceAllButton: NSButton!
    
    @IBOutlet weak var issueResultsPreferenceAssignedIssuesButton: NSButton!
    
    var preferences: JiraBridgePreferences!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.preferences = JiraBridgePreferences()
        self.preferences.delegate = self
        
       displayPreferences(preferences: self.preferences)
    }
    
    func displayPreferences(preferences: JiraBridgePreferences) {
        displayPreference(searchableIssuesPreference: preferences.searchableIssues)
    }
    
    func displayPreference(searchableIssuesPreference: SearchableIssuesPreference) {
        issueResultsPreferenceAllButton.state = searchableIssuesPreference == .all ? .on : .off
        issueResultsPreferenceAssignedIssuesButton.state = searchableIssuesPreference == .userAssigned ? .on : .off
    }
    
    @IBAction func issueResultsRadioButtonChanged(_ sender: NSButton) {
        if sender == issueResultsPreferenceAssignedIssuesButton {
            preferences.setSearchIssues(searchableIssuesPreference: .userAssigned)
        } else if sender == issueResultsPreferenceAllButton {
              preferences.setSearchIssues(searchableIssuesPreference: .all)
        }
    }
}

extension JiraBridgePreferencesViewController: JiraBridgePreferencesDelegate {
    func didUpdatePreferences(preferences: JiraBridgePreferences) {
        self.displayPreferences(preferences: preferences)
    }
}
