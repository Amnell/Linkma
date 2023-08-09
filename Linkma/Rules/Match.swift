//
//  Match.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-09.
//

import Foundation

struct Match: Codable {
    let rule: Rule
    let stringItem: PasteboardStringItem

    var url: URL? {
        URL(rule: rule, pasteboardItem: stringItem)
    }
}
