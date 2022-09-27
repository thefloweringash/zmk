//
//  Glove80ColorApp.swift
//  Glove80Color
//
//  Created by Andrew Childs on 2022/09/27.
//

import SwiftUI

@main
struct Glove80ColorApp: App {
    init() {
        let blink1 = Blink1.singleton
        let daemon = Thread(target: blink1, selector:#selector(Blink1.initUsb), object: nil)
        daemon.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
