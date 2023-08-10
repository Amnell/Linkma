//
//  URL+rule.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-10.
//

import Foundation

extension URL {
    init?(rule: Rule, pasteboardItem: PasteboardStringItem) {
        do {
            let urlString = try pasteboardItem.string.replacingGroups(matching: try Regex(rule.regex), with: rule.urlString)
            if let url = URL(string: urlString) {
                self = url
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
