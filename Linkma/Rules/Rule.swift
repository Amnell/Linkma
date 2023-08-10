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
    var browserOptions: BrowserOptions

    init(regex: String, url: String) {
        self.uuid = UUID()
        self.date = Date()
        self.regex = regex
        self.urlString = url
        self.browserOptions = BrowserOptions(browser: .system)
    }

    var isValidRegex: Bool {
        if let _ = try? Regex(regex) {
            return true
        }

        return false
    }

    func verify(string: String) throws -> Bool {
        let regex = try Regex(regex)
        let matches = string.matches(of: regex)
        return matches.count == 1
    }

    static func empty() -> Rule {
        Rule(regex: "", url: "")
    }
    
    enum CodingKeys: CodingKey {
        case uuid
        case name
        case date
        case regex
        case urlString
        case browserOptions
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<Rule.CodingKeys> = try decoder.container(keyedBy: Rule.CodingKeys.self)
        
        self.uuid = try container.decode(UUID.self, forKey: Rule.CodingKeys.uuid)
        self.name = try container.decodeIfPresent(String.self, forKey: Rule.CodingKeys.name)
        self.date = try container.decode(Date.self, forKey: Rule.CodingKeys.date)
        self.regex = try container.decode(String.self, forKey: Rule.CodingKeys.regex)
        self.urlString = try container.decode(String.self, forKey: Rule.CodingKeys.urlString)

        let browserOptions = try container.decodeIfPresent(BrowserOptions.self, forKey: Rule.CodingKeys.browserOptions)
        self.browserOptions = browserOptions ?? BrowserOptions(browser: .system)
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<Rule.CodingKeys> = encoder.container(keyedBy: Rule.CodingKeys.self)
        
        try container.encode(self.uuid, forKey: Rule.CodingKeys.uuid)
        try container.encodeIfPresent(self.name, forKey: Rule.CodingKeys.name)
        try container.encode(self.date, forKey: Rule.CodingKeys.date)
        try container.encode(self.regex, forKey: Rule.CodingKeys.regex)
        try container.encode(self.urlString, forKey: Rule.CodingKeys.urlString)
        try container.encode(self.browserOptions, forKey: Rule.CodingKeys.browserOptions)
    }
}

extension Rule: Hashable, Equatable {
}

extension Rule: Identifiable {
    var id: UUID {
        uuid
    }
}
