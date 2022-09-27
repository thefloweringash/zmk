//
//  ContentView.swift
//  Glove80Color
//
//  Created by Andrew Childs on 2022/09/27.
//

import SwiftUI

struct ContentView: View {
    @State private var bgColor =
        CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    var body: some View {
        VStack {
            ColorPicker("Backlight Color", selection: $bgColor)
        }
        .onChange(of: bgColor) { newValue in
            print("Sending color change notification")
            NotificationCenter.default.post(
                name: Notification.Name("glove80colorChanged"),
                object: nil,
                userInfo: ["color": newValue])
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
