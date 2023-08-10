//
//  PasteboardListener.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-07.
//

import Foundation
import AppKit

class PasteboardListener: ObservableObject {
    private var timer: Timer?
    private let pasteboard: NSPasteboard = .general
    private var lastChangeCount: Int = 0

    @Published var stringItems: [PasteboardStringItem] = []

    func start() {
        guard timer == nil || timer?.isValid == false else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.lastChangeCount != self.pasteboard.changeCount {
                self.lastChangeCount = self.pasteboard.changeCount
                NotificationCenter.default.post(name: .pasteboardDidChange, object: self.pasteboard)

                let strings = self.pasteboard.pasteboardItems?.compactMap { PasteboardStringItem(pasteboardItem: $0) } ?? []
                stringItems.append(contentsOf: strings)
            }
        }
    }

    func stop() {
        timer?.invalidate()
    }
}

extension NSNotification.Name {
    public static let pasteboardDidChange: NSNotification.Name = .init(rawValue: "pasteboardDidChangeNotification")
}

extension NSPasteboardItem: Identifiable {
    
}
