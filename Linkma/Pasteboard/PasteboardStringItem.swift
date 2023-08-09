//
//  PasteboardStringItem.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-08.
//

import AppKit

struct PasteboardStringItem: Codable, Hashable {
    let date: Date
    let string: String

    init?(pasteboardItem: NSPasteboardItem) {
        guard let string = pasteboardItem.string(forType: .string) else { return nil }
        self.date = Date()
        self.string = string
    }
}

extension PasteboardStringItem: Identifiable {
    var id: Int {
        hashValue
    }
}
