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
