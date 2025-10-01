//
//  PasteboardAccessView.swift
//  Linkma
//
//  Created by Mathias Amnell on 2023-08-07.
//

import SwiftUI

struct PasteboardAccessView: View {
    @EnvironmentObject var pasteboardListener: PasteboardListener
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clipboard Access")
                        .font(.headline)
                    Text("Required for Linkma to monitor clipboard changes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                // Access status indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(pasteboardListener.hasPasteboardAccess ? .green : .red)
                        .frame(width: 8, height: 8)
                    
                    Text(pasteboardListener.hasPasteboardAccess ? "Access Granted" : "Access Required")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 12) {
                    if !pasteboardListener.hasPasteboardAccess {
                        Button("Request Access") {
                            pasteboardListener.requestAccess()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    
                    Button("Open System Settings") {
                        pasteboardListener.openSystemSettings()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            if !pasteboardListener.hasPasteboardAccess {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to grant access:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 8) {
                            Text("1.")
                                .fontWeight(.medium)
                            Text("Click 'Request Access' to trigger permission dialog")
                        }
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("2.")
                                .fontWeight(.medium)
                            Text("If no dialog appears, click 'Open System Settings'")
                        }
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("3.")
                                .fontWeight(.medium)
                            Text("Navigate to Privacy & Security → Clipboard")
                        }
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("4.")
                                .fontWeight(.medium)
                            Text("Enable Linkma in the list of applications")
                        }
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("5.")
                                .fontWeight(.medium)
                            Text("If Clipboard section is missing, try copying some text first")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    PasteboardAccessView()
        .environmentObject(PasteboardListener())
        .frame(width: 400)
}
