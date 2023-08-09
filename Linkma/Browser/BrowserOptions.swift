//
//  BrowserOptions.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-08.
//

import Foundation
import AppKit

public struct BrowserOptions: Codable {
    public var browser: Browser
    public var profile: String?

    public var description: String {
        String(describing: browser)
    }

    public init(
        browser: Browser,
        profile: String? = nil
    ) {
        self.browser = browser
        self.profile = profile
    }
}

extension BrowserOptions: Hashable {}
