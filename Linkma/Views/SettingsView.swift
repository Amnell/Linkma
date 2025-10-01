//
//  SettingsView.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-07.
//

import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    @EnvironmentObject var rulesService: RulesStore
    @EnvironmentObject var pasteboardListener: PasteboardListener
    @State var selectedRule: Rule?

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Pasteboard Access Section
                PasteboardAccessView()
                    .padding(.horizontal)
                    .padding(.top)
                
                Divider()
                    .padding(.vertical, 8)
                
                // Rules Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Rules")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            let newRule = Rule.empty()
                            try? rulesService.save(rule: newRule)
                            selectedRule = newRule
                        }, label: {
                            Image(systemName: "plus")
                        })
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.horizontal)
                    
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
                }
            }
            .navigationSplitViewStyle(.prominentDetail)
            .navigationSplitViewColumnWidth(350)
        } detail: {
            if let selectedRule, rulesService.rules.contains(where: { $0.uuid == selectedRule.uuid }) {
                RuleView(rule: $selectedRule.withDefault(Rule.empty()))
                    .id(selectedRule)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Select a rule to edit")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Create a new rule or select an existing one from the list")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .font(.subheadline)
                Text(rule.urlString)
                    .font(.subheadline)
            }
        }
    }
}
