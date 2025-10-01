//
//  Logger.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-07.
//

import Foundation
import os.log

/// Logging categories for Linkma
enum LogCategory: String, CaseIterable {
    case pasteboard = "Pasteboard"
    case rules = "Rules"
    case notifications = "Notifications"
    case app = "App"
    case browser = "Browser"
    case settings = "Settings"
    
    var subsystem: String {
        return "se.apping.Linkma"
    }
}

/// Extensions on os.log.Logger for structured logging in Linkma
extension Logger {
    // MARK: - Category-specific Loggers
    static let pasteboard = Logger(subsystem: LogCategory.pasteboard.subsystem, category: LogCategory.pasteboard.rawValue)
    static let rules = Logger(subsystem: LogCategory.rules.subsystem, category: LogCategory.rules.rawValue)
    static let notifications = Logger(subsystem: LogCategory.notifications.subsystem, category: LogCategory.notifications.rawValue)
    static let app = Logger(subsystem: LogCategory.app.subsystem, category: LogCategory.app.rawValue)
    static let browser = Logger(subsystem: LogCategory.browser.subsystem, category: LogCategory.browser.rawValue)
    static let settings = Logger(subsystem: LogCategory.settings.subsystem, category: LogCategory.settings.rawValue)
}
