//
//  RuleView.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-08.
//

import SwiftUI

struct RuleView: View {
    @EnvironmentObject var rulesService: RulesStore

    let rule: Rule

    @State private var name: String = ""
    @State private var regex: String = ""
    @State private var urlString: String = ""
    @State private var browser: Browser = .system
    @State private var profile: String = ""

    var isValidRegex: Bool {
        if let _ = try? Regex(regex) {
            return true
        } else {
            return false
        }
    }

    init(rule: Rule) {
        self.rule = rule
        self._name = State(initialValue: rule.name ?? "")
        self._regex = State(initialValue: rule.regex)
        self._urlString = State(initialValue: rule.urlString)
        self._browser = State(initialValue: rule.browserOptions?.browser ?? .system)
        self._profile = State(initialValue: rule.browserOptions?.profile ?? "")
    }

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Regex", text: $regex)
            TextField("URL", text: $urlString)

            Picker("Browser", selection: $browser) {
                ForEach(Browser.allCases) { browser in
                    Text(browser.name)
                        .tag(browser)
                }
            }

            if browser.supportsProfiles {
                TextField("Profile", text: $profile)
            }

            HStack {
                Button("Save") {
                    save()
                }.disabled(!isValidRegex)

                if !isValidRegex {
                    Text("Invalid regular expression")
                        .foregroundStyle(.red)
                }
            }

            Spacer()
        }
        .padding()
        .toolbar {
            Button(action: {
                if let index = rulesService.rules.firstIndex(of: rule) {
                    try! rulesService.remove(atOffsets: IndexSet(integer: index))
                }
            }, label: {
                Image(systemName: "trash")
            })
        }
        .navigationTitle($name)
    }

    func save() {
        do {
            var rule = self.rule
            rule.name = name.isEmpty ? nil : name
            rule.regex = regex
            rule.urlString = urlString
            rule.browserOptions = BrowserOptions(browser: browser, profile: profile.isEmpty ? nil : profile)

            try rulesService.save(rule: rule)
        } catch {
            print(error)
        }
    }
}

struct RuleView_Previews: PreviewProvider {
    static var previews: some View {
        RuleView(rule: Rule.empty())
            .environmentObject(RulesStore(userDefaults: .standard))
    }
}

