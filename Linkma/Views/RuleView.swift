//
//  RuleView.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-08.
//

import SwiftUI

struct RuleView: View {
    @EnvironmentObject var rulesService: RulesStore

    @Binding var rule: Rule
    @State private var backingRule: Rule

    init(rule: Binding<Rule>) {
        self._rule = rule
        self._backingRule = State(initialValue: rule.wrappedValue)
    }

    var body: some View {
        Form {
            let _ = Self._printChanges()
            Section {
                TextField("Name", text: $backingRule.name.withDefault(""))
                TextField("Regex", text: $backingRule.regex)
                TextField("URL", text: $backingRule.urlString)
            }

            Picker("Browser", selection: $backingRule.browserOptions.browser) {
                ForEach(Browser.allCases) { browser in
                    Text(browser.name)
                        .tag(browser)
                }
            }

            if backingRule.browserOptions.browser.supportsProfiles {
                TextField("Profile", text: $backingRule.browserOptions.profile.withDefault(""))
            }

            HStack {
                Button("Save") {
                    save()
                }.disabled(!backingRule.isValidRegex)

                if !backingRule.isValidRegex {
                    Text("Invalid regular expression")
                        .foregroundStyle(.red)
                }
            }

            Spacer()
        }
        .padding()
        .toolbar {
            Button(action: {
                delete()
            }, label: {
                Image(systemName: "trash")
            })
        }
        .navigationTitle(rule.name ?? "Rule")
    }

    func save() {
        do {
            self.rule = backingRule
            try rulesService.save(rule: rule)
        } catch {
            print(error)
        }
    }

    func delete() {
        do {
            try rulesService.delete(rule: rule)
        } catch {
            print(error)
        }
    }
}

struct RuleView_Previews: PreviewProvider {
    static var previews: some View {
        RuleView(rule: .constant(Rule.empty()))
            .environmentObject(RulesStore(userDefaults: .standard))
    }
}

