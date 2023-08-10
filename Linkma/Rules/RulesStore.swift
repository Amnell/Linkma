//
//  RulesStore.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-07.
//

import Foundation

class RulesStore: ObservableObject {
    @Published var rules: [Rule]
    let userDefaults: UserDefaults

    init(rules: [Rule] = [], userDefaults: UserDefaults) {
        self.rules = rules
        self.userDefaults = userDefaults

        try? fetch()
    }

    func fetch() throws {
        if let data = userDefaults.data(forKey: "rules") {
            self.rules = try JSONDecoder().decode([Rule].self, from: data)
        }
    }

    func persist() throws {
        let data = try JSONEncoder().encode(rules)
        userDefaults.setValue(data, forKey: "rules")
    }

    func save(rule: Rule) throws {
        if let existingRuleIndex = rules.firstIndex(where: { $0.uuid == rule.uuid }) {
            rules[existingRuleIndex] = rule
        } else {
            rules.insert(rule, at: 0)
        }
        try persist()
    }

    func delete(rule: Rule) throws {
        if let index = rules.firstIndex(of: rule) {
            try delete(atOffsets: IndexSet(integer: index))
        }
    }

    func delete(atOffsets: IndexSet) throws {
        rules.remove(atOffsets: atOffsets)
        try persist()
    }
}
