//
//  Shell.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-08.
//

import Foundation

@discardableResult
func shell(_ args: [String]) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}
