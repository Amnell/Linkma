//
//  Binding.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-10.
//

import SwiftUI

extension Binding {
    func withDefault<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return Binding<T>(get: {
            self.wrappedValue ?? defaultValue
        }, set: { newValue in
            self.wrappedValue = newValue
        })
    }
}
