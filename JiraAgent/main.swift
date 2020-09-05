//
//  main.swift
//  JiraAgent
//
//  Created by Benjamin Johnson on 31/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JiraKit


let configurationURL = Bundle.main.url(forResource: "jiraconfig", withExtension: "json")!
guard let configuration = JiraSessionConfiguration.fromFile(for: configurationURL) else {
    fatalError("Unable to load configuration")
}

let agent = JiraAgent(configuration: configuration)
agent.start()

RunLoop.current.run()
