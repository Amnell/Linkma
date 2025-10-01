//
//  PasteboardListener.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-07.
//

import Foundation
import AppKit
import os.log

class PasteboardListener: ObservableObject {
    private let pasteboard: NSPasteboard = .general
    private var lastChangeCount: Int = 0

    @Published var pasteboardStrings: [PasteboardStringItem] = []
    @Published var hasPasteboardAccess: Bool = false

    func start() {
        guard pollingTimer == nil else { return }
        Logger.pasteboard.info("Starting pasteboard listener")

        // Always request pasteboard access to ensure we have it
        // This will either confirm existing access or request new access
        requestPasteboardAccess { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPasteboardAccess = granted
                if granted {
                    Logger.pasteboard.info("Pasteboard access confirmed - setting up observer")
                    self?.setupPasteboardObserver()
                } else {
                    Logger.pasteboard.warning("Pasteboard access denied - cannot monitor clipboard")
                }
            }
        }
    }
    
    private func requestPasteboardAccess(completion: @escaping (Bool) -> Void) {
        // For macOS 16.0+, we need to request pasteboard access
        // The first access to the pasteboard will trigger the system permission dialog
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                completion(false)
                return
            }
            
            Logger.pasteboard.info("Requesting pasteboard access...")
            
            // Try to access the pasteboard content - this will trigger permission request if needed
            let changeCount = self.pasteboard.changeCount
            Logger.pasteboard.debug("Pasteboard change count: \(changeCount)")
            
            // Try to actually read pasteboard content to verify access
            // This is what triggers the permission dialog on macOS 16.0+
            let pasteboardItems = self.pasteboard.pasteboardItems
            let stringContent = self.pasteboard.string(forType: .string)
            
            // On macOS 16.0+, if we don't have permission, pasteboardItems will be nil
            let hasAccess = pasteboardItems != nil
            
            Logger.pasteboard.info("Pasteboard access result: \(hasAccess ? "granted" : "denied")")
            if hasAccess {
                Logger.pasteboard.debug("String content available: \(stringContent != nil ? "yes" : "no")")
                Logger.pasteboard.debug("Pasteboard items count: \(pasteboardItems?.count ?? 0)")
            } else {
                Logger.pasteboard.warning("Cannot access pasteboard items - permission required")
            }
            
            completion(hasAccess)
        }
    }
    
    private func setupPasteboardObserver() {
        // Initialize with current change count
        lastChangeCount = pasteboard.changeCount
        Logger.pasteboard.info("Setting up pasteboard monitoring with initial change count: \(self.lastChangeCount)")
        
        // KVO doesn't work reliably with NSPasteboard.changeCount, so we use polling
        // This is the most reliable approach for clipboard monitoring
        startPolling()
    }
    
    private var pollingTimer: Timer?
    
    private func startPolling() {
        // Stop any existing timer
        pollingTimer?.invalidate()
        
        // Start polling every 1 second - this is the most reliable approach
        // for clipboard monitoring on macOS
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkForPasteboardChanges()
        }
        Logger.pasteboard.info("Started pasteboard polling timer (1 second interval)")
    }
    
    private func checkForPasteboardChanges() {
        let currentChangeCount = pasteboard.changeCount
        if currentChangeCount != lastChangeCount {
            Logger.pasteboard.debug("Pasteboard change detected: \(self.lastChangeCount) -> \(currentChangeCount)")
            lastChangeCount = currentChangeCount
            processPasteboardChanges()
        }
    }

    func stop() {
        Logger.pasteboard.info("Stopping pasteboard listener")
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    func requestAccess() {
        Logger.pasteboard.info("Manually requesting pasteboard access")
        
        // Force a permission dialog by actually trying to read clipboard content
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            Logger.pasteboard.info("Attempting to read clipboard content to trigger permission dialog...")
            
            // This should trigger the permission dialog if it hasn't been shown yet
            let _ = self.pasteboard.string(forType: .string)
            let _ = self.pasteboard.pasteboardItems
            
            // Now check the actual access status
            DispatchQueue.main.async {
                self.requestPasteboardAccess { granted in
                    self.hasPasteboardAccess = granted
                    if granted {
                        self.setupPasteboardObserver()
                        Logger.pasteboard.info("Pasteboard access granted after manual request")
                    } else {
                        Logger.pasteboard.warning("Pasteboard access still denied - user may need to grant permission in System Settings")
                    }
                }
            }
        }
    }
    
    func openSystemSettings() {
        // Try multiple approaches to open System Settings to clipboard permissions
        Logger.settings.info("Opening System Settings for clipboard permissions...")
        
        // Method 1: Try the modern System Settings URL (macOS 13+)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Clipboard") {
            Logger.settings.debug("Trying modern System Settings URL...")
            NSWorkspace.shared.open(url)
            return
        }
        
        // Method 2: Try opening System Preferences directly
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security") {
            Logger.settings.debug("Trying System Preferences URL...")
            NSWorkspace.shared.open(url)
            return
        }
        
        // Method 3: Open System Settings app directly
        Logger.settings.debug("Opening System Settings app directly...")
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.systempreferences") {
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { _, _ in }
        } else {
            // Fallback to opening System Settings via URL
            if let settingsURL = URL(string: "x-apple.systempreferences:") {
                NSWorkspace.shared.open(settingsURL)
            }
        }
        
        // Method 4: Show instructions to user
        Logger.settings.info("Please manually navigate to: System Settings > Privacy & Security > Clipboard")
    }
    
    func checkCurrentAccessStatus() -> Bool {
        // Check current access status without triggering permission request
        // Try to read both changeCount and pasteboardItems to get a more accurate assessment
        let changeCount = pasteboard.changeCount
        let pasteboardItems = pasteboard.pasteboardItems
        
        // If we can't get pasteboardItems, we definitely don't have access
        guard pasteboardItems != nil else {
            print("checkCurrentAccessStatus: No access (pasteboardItems is nil)")
            return false
        }
        
        // Try to read string content to verify we can actually access the data
        let stringContent = pasteboard.string(forType: .string)
        
        Logger.pasteboard.debug("checkCurrentAccessStatus: Access granted (changeCount: \(changeCount), stringContent: \(stringContent != nil ? "available" : "nil"))")
        return true
    }
    
    private func processPasteboardChanges() {
        Logger.pasteboard.debug("Processing pasteboard changes...")
        
        // Process the new pasteboard content
        let pasteboardItems = pasteboard.pasteboardItems
        Logger.pasteboard.debug("Pasteboard items: \(pasteboardItems?.count ?? 0)")
        
        let strings = pasteboardItems?.compactMap { PasteboardStringItem(pasteboardItem: $0) } ?? []
        Logger.pasteboard.debug("Extracted string items: \(strings.count)")
        
        // Log the actual content for debugging
        for (index, stringItem) in strings.enumerated() {
            Logger.pasteboard.debug("String item \(index): '\(stringItem.string.prefix(50))...'")
        }
        
        // Only add if we have new content
        if !strings.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.pasteboardStrings.append(contentsOf: strings)
                Logger.pasteboard.info("Added \(strings.count) string items to the list")
            }
        } else {
            Logger.pasteboard.debug("No new string content found")
        }
    }
    
    deinit {
        stop()
    }
}

extension NSPasteboardItem: @retroactive Identifiable {
    
}
