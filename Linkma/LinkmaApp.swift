//
//  LinkmaApp.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-07.
//

import AppKit
import UserNotifications
import Combine
import SwiftUI
import LaunchAtLogin

@main
struct LinkmaApp: App {
    @NSApplicationDelegateAdaptor var delegate: AppDelegate

    @Environment(\.openWindow) var openWindow
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        MenuBarExtra("Linkma", systemImage: "link.circle.fill") {
            Button(action: {
                openSettingsWindow()
            }, label: {
                Text("Rules")
            })

            LaunchAtLogin.Toggle()

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)

        WindowGroup("Settings", id: "settings") {
            SettingsView()
                .environmentObject(delegate.rulesService)
        }.windowResizability(.contentSize)
    }

    func openSettingsWindow() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        openWindow(id: "settings")
    }
}
