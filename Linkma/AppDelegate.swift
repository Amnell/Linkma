//
//  AppDelegate.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-08.
//

import AppKit
import UserNotifications
import Combine
import os.log

class AppDelegate: NSObject, NSApplicationDelegate {
    var pasteboardListener: PasteboardListener = PasteboardListener()
    var rulesService: RulesStore = RulesStore(userDefaults: .standard)

    private var cancellables = Set<AnyCancellable>()

    func applicationWillFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        pasteboardListener.start()

        // Monitor pasteboard access status
        pasteboardListener.$hasPasteboardAccess
            .sink { hasAccess in
                if hasAccess {
                    Logger.app.info("Pasteboard access granted")
                } else {
                    Logger.app.warning("Pasteboard access denied - user needs to grant permission")
                    // You could show a notification or alert here to inform the user
                }
            }.store(in: &cancellables)

        pasteboardListener.$pasteboardStrings
            .compactMap({$0.last})
            .dropFirst()
            .sink { [weak self] stringItem in
                Task {
                    await self?.handleStringItem(stringItem: stringItem)
                }
            }.store(in: &cancellables)

        setupNotification()
    }

    @MainActor
    func handleStringItem(stringItem: PasteboardStringItem) async {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay to allow for rapid changes
        let keys: [String: Bool] = [
            "shift": NSEvent.modifierFlags.contains(.shift),
            "option": NSEvent.modifierFlags.contains(.option),
            "command": NSEvent.modifierFlags.contains(.command),
            "control": NSEvent.modifierFlags.contains(.control),
        ]

        Logger.rules.info("Handling new pasteboard string item: \(stringItem.string)")
        for rule in self.rulesService.rules {
            Logger.rules.debug("Checking rule: \(rule.name ?? "unnamed") with regex: \(rule.regex)")
            do {
                if try rule.verify(string: stringItem.string) {
                    Logger.rules.info("Rule matched: \(rule.name ?? "unnamed")")
                    let match = Match(rule: rule, stringItem: stringItem)
                    if keys["shift"] == true {
                        openMatch(match)
                    } else {
                        self.generateNotification(match: match)
                    }
                    break
                }
            } catch {
                Logger.rules.error("Error verifying rule '\(rule.name ?? "unnamed")': \(error.localizedDescription)")
            }
        }
    }

    func setupNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { granted, error in
            if error != nil {
                print ("Request notifications permission Error");
            }

            if granted {
                print ("Notifications allowed");
            } else
            {
                print ("Notifications denied");
            }
        }
    }

    func generateNotification(match: Match) {
        guard let url = match.url else { return }

        let content = UNMutableNotificationContent()
        content.title = "Rule trigger"
        content.subtitle = "Rule with regex \(match.rule.regex) triggered"
        content.body = "Click to open \(url.absoluteString) in your default browser"
        content.interruptionLevel = .critical
        content.userInfo = [
            "match": try! JSONEncoder().encode(match)
        ]

        let request = UNNotificationRequest(identifier: "rule-trigger", content: content, trigger: .none)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.notifications.error("Failed to show notification: \(error.localizedDescription)")
            }
        }
    };
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        // Show banner even if app is active
        UNNotificationPresentationOptions.banner
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        do {
            if let matchData = response.notification.request.content.userInfo["url"] as? Data {
                let match = try JSONDecoder().decode(Match.self, from: matchData)
                openMatch(match)
            }
        } catch {
            Logger.notifications.error("Failed to decode match from notification: \(error.localizedDescription)")
        }
    }
}
