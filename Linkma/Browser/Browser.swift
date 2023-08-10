//
//  Browser.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-08.
//

import AppKit
import Foundation

func openMatch(_ match: Match) {
    if let url = match.url {
        openUrlWithOptions(url, options: match.rule.browserOptions)
    }
}

public func openUrlWithOptions(_ url: URL, options: BrowserOptions) {
    if options.browser != .system {
        let command = getBrowserCommand(options, url: url)
        shell(command)
    } else {
        NSWorkspace.shared.open(url)
    }
}

// keep all browser bundle IDs lowercase
public enum Browser: String, CaseIterable, Codable, Identifiable {
    case system = "–system-"
    case chrome = "com.google.chrome"
    case chromeCanary = "com.google.chrome.canary"
    case edge = "com.microsoft.edgemac"
    case edgeBeta = "com.microsoft.edgemac.beta"
    case firefox = "org.mozilla.firefox"
    case opera = "com.operasoftware.opera"
    case safari = "com.apple.safari"

    var name: String {
        switch self {
        case .system:
            return "Default"
        case .chrome:
            return "Chrome"
        case .chromeCanary:
            return "Chrome Canary"
        case .edge:
            return "Edge"
        case .edgeBeta:
            return "Edge Beta"
        case .firefox:
            return "Firefox"
        case .opera:
            return "Opera"
        case .safari:
            return "Safari"
        }
    }

    var supportsProfiles: Bool {
        switch self {
        case .chrome, .edge, .edgeBeta:
            return true
        default:
            return false
        }
    }

    public var id: String {
        rawValue
    }
}

public func getBrowserCommand(_ browserOpts: BrowserOptions, url: URL) -> [String] {
    var command = ["open"]
    var commandArgs: [String] = []

    let bundleId = browserOpts.browser.rawValue

    // Don't add bundleId if browser is set to system
    if browserOpts.browser != .system {
        command.append(contentsOf: ["-b", bundleId])
    }

    command.append(url.absoluteString)

    if let profile = browserOpts.profile {
        if let profileOption: [String] = getProfileOption(browser: browserOpts.browser, profile: profile) {
            commandArgs.append(contentsOf: profileOption)
        }
    }

    if !commandArgs.isEmpty {
        command.append("--args")
        command.append(contentsOf: commandArgs)
    }

    return command
}

private func getProfileOption(browser: Browser, profile: String) -> [String]? {
    var profileOption: [String]? {
        if browser.supportsProfiles {
            return ["--profile-directory=\(profile)"]
        } else {
            return nil
        }
    }
    return profileOption
}
