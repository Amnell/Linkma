//
//  AppDelegate.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-08.
//

import AppKit
import UserNotifications
import Combine

extension URL {
    init?(rule: Rule, pasteboardItem: PasteboardStringItem) {
        let urlString = rule.urlString.replacingOccurrences(of: "$0", with: pasteboardItem.string)
        if let url = URL(string: urlString) {
            self = url
        } else {
            return nil
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var pasteboardListener: PasteboardListener = PasteboardListener()
    var rulesService: RulesStore = RulesStore(userDefaults: .standard)

    private var cancellables = Set<AnyCancellable>()

    func applicationWillFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        print(#function)
        pasteboardListener.start()

        pasteboardListener.$stringItems
            .breakpoint()
            .compactMap({$0.last})
            .dropFirst()
            .sink { [weak self] stringItem in
                self?.handleStringItem(stringItem: stringItem)
            }.store(in: &cancellables)

        setupNotification()
    }

    func handleStringItem(stringItem: PasteboardStringItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let keys: [String: Bool] = [
                "shift": NSEvent.modifierFlags.contains(.shift),
                "option": NSEvent.modifierFlags.contains(.option),
                "command": NSEvent.modifierFlags.contains(.command),
                "control": NSEvent.modifierFlags.contains(.control),
            ]

            for rule in self.rulesService.rules {
                do {
                    if try rule.verify(string: stringItem.string) {
                        let match = Match(rule: rule, stringItem: stringItem)
                        if keys["shift"] == true {
                            openMatch(match)
                        } else {
                            self.generateNotification(match: match)
                        }
                        break
                    }
                } catch {
                    print(error)
                }
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
                print(error)
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
            print(error)
        }
    }
}
