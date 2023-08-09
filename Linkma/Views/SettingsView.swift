//
//  SettingsView.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-07.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var rulesService: RulesStore
    @State var selectedRule: Rule?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedRule) {
                ForEach($rulesService.rules, id: \.uuid, editActions: .move) { $rule in
                    NavigationLink(value: rule) {
                        RuleRowView(rule: rule)
                    }
                    .id(rule.uuid)
                }
                .onMove { indices, destination in
                    rulesService.rules.move(fromOffsets: indices, toOffset: destination)
                    try? rulesService.persist()
                }
            }
            .listStyle(.inset)
            .toolbar {
                ToolbarItem {
                    Spacer()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        let newRule = Rule.empty()
                        try? rulesService.save(rule: newRule)
                        selectedRule = newRule
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        } detail: {
            if let selectedRule, rulesService.rules.contains(where: { $0.uuid == selectedRule.uuid }) {
                RuleView(rule: selectedRule)
                    .id(selectedRule)
            } else {
                VStack {
                    Text("select rule")
                }
            }
        }
        .onAppear(perform: {
            try? rulesService.fetch()
        })
    }
}
// POTATO-123
//
//#Preview {
//    RulesView()
//}

struct RulesView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(RulesStore(userDefaults: .standard))
    }
}

struct RuleRowView: View {
    let rule: Rule

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundStyle(.green)
            
            VStack(alignment: .leading) {
                Text(rule.name ?? "Unnamed")
                Text(rule.regex)
                Text(rule.urlString)
                    .font(.subheadline)
                Text(rule.uuid.uuidString)
                    .font(.footnote)
            }
        }
    }
}
