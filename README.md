# SpotlightBridgeExtensionJIRA
A Spotlight Bridge extension that integrates JIRA search results into macOS Spotlight.

## Requirements
- Spotlight Bridge

## Installation
1. Create the configuration file `jiraconfig.json` inside the `JIRASpotlightBridgeExtension` directory. This file will contain the authentication details for the JIRA instance you wish to connect with.
It should contain the following contents:
```
{
    "domain": "https://<sitename>.jira.com",
    "username": "<username>",
    "authToken":"<authtoken>"
}
```

2. Build the `JIRASpotlightBridgeExtension` target in Xcode. The extension bundle will be automatically copied to `~/Library/Application Support/SpotlightBridge/`.
3. Restart Spotlight

## Architecture

### Jira Spotlight Bridge Extension
The extension bundle that adds Jira issue results to Spotlight. This extension bundle talks to the Jira Agent and translates the responses into Spotlight results. It also contains the Jira Issue card UI for Spotlight.

### Jira Agent
This is the main XPC service process that performs all the querying of the Jira Issues on behalf of the extension. It also contains the CoreData stack to support local cacheing.

### Jira Bridge
Provides the preferences GUI and acts as a container for the Jira Agent and Jira Spotlight Extension.
