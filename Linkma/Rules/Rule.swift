//
//  Rule.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-07.
//

import Foundation

struct Rule: Codable {
    let uuid: UUID
    var name: String?
    var date: Date
    var regex: String
    var urlString: String
    var browserOptions: BrowserOptions?

    init(regex: String, url: String) {
        self.uuid = UUID()
        self.date = Date()
        self.regex = regex
        self.urlString = url
    }

    var isValid: Bool {
        return true
    }

    func verify(string: String) throws -> Bool {
        let regex = try Regex(regex)
        let matches = string.matches(of: regex)
        return matches.count == 1
    }

    static func empty() -> Rule {
        Rule(regex: "", url: "")
    }
}

extension Rule: Hashable, Equatable {
}

extension Rule: Identifiable {
    var id: UUID {
        uuid
    }
}
