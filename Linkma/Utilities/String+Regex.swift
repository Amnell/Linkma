//
//  String+RegexGroup.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-10.
//

import Foundation

extension String {
    public mutating func replaceGroups(matching regex: Regex<AnyRegexOutput>, with template: String) throws {
        let groupPlaceholderRegex = try Regex(#"\$(\d+)"#)

        matches(of: regex).forEach { match in
            var matchedGroups: [Int : String] = [:]
            for rangeIndex in 0 ..< match.output.count {
                if let substring = match.output[rangeIndex].substring {
                    matchedGroups[rangeIndex] = String(substring)
                }
            }

            var placeholders: [(subrange: Range<String.Index>, replacement: String)] = []
            let templateMatches = template.matches(of: groupPlaceholderRegex)
            templateMatches.forEach { match in
                guard match.output.count >= 2 else { return }
                guard let indexSubstring = match.output[1].substring, let index = Int(indexSubstring) else { return }
                guard let range = match.output[0].range else { return }

                if index < matchedGroups.count {
                    placeholders.append((subrange: range, matchedGroups[index]!))
                } else {
                    assertionFailure("Index out of bounds")
                }
            }

            var template = template
            placeholders.sorted(by: {$0.subrange.upperBound > $1.subrange.upperBound}).forEach { placeholder in
                template.replaceSubrange(placeholder.subrange, with: placeholder.replacement)
            }

            self = template
        }
    }

    public func replacingGroups(matching regex: Regex<AnyRegexOutput>, with template: String) throws -> String {
        var mutableSelf = self
        try mutableSelf.replaceGroups(matching: regex, with: template)
        return mutableSelf
    }
}
