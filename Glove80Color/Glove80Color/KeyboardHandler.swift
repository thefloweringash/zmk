//
//  Blink1.swift
//  KuandoSwift
//
//  Created by Eric Betts on 6/19/15.
//  Copyright © 2015 Eric Betts. All rights reserved.
//

import Foundation
import IOKit.hid

class Blink1 : NSObject {
    let vendorId = 0x16c0
    let productId = 0x27db
    let reportSize = 8 //Device specific
    static let singleton = Blink1()
    var device : IOHIDDevice? = nil

    // https://medium.com/simple-swift-programming-tips/how-to-convert-rgb-to-hue-in-swift-1d25338cad28
    func rgbToHue(r:CGFloat,g:CGFloat,b:CGFloat) -> (h:CGFloat, s:CGFloat, b:CGFloat) {
        let minV:CGFloat = CGFloat(min(r, g, b))
        let maxV:CGFloat = CGFloat(max(r, g, b))
        let delta:CGFloat = maxV - minV
        var hue:CGFloat = 0
        if delta != 0 {
            if r == maxV {
               hue = (g - b) / delta
            }
            else if g == maxV {
               hue = 2 + (b - r) / delta
            }
            else {
               hue = 4 + (r - g) / delta
            }
            hue *= 60
            if hue < 0 {
               hue += 360
            }
        }
        let saturation = maxV == 0 ? 0 : (delta / maxV)
        let brightness = maxV
        return (h:hue, s:saturation, b:brightness)
    }

    func input(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, type: IOHIDReportType, reportId: UInt32, report: UnsafeMutablePointer<UInt8>, reportLength: CFIndex) {
        let message = Data(bytes: report, count: reportLength)
        print("Input received: \(message)")
    }

    func output(_ data: Data) {
        if (data.count > reportSize) {
            print("output data too large for USB report")
            return
        }
        guard let blink1 = device else {
            print("Not outputting, no device")
            return
        }
        let reportId : CFIndex = CFIndex(data[0])
        print("Senting output: \([UInt8](data))")
        let result = IOHIDDeviceSetReport(blink1, kIOHIDReportTypeOutput, reportId, [UInt8](data), data.count)
        print("Senting result: \(result)")
    }

    func connected(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, inIOHIDDeviceRef: IOHIDDevice!) {
        print("Device connected")
        // It would be better to look up the report size and create a chunk of memory of that size
        device = inIOHIDDeviceRef
    }

    func removed(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, inIOHIDDeviceRef: IOHIDDevice!) {
        print("Device removed")
    }

    func sendColor(_ color: CGColor) {
        let reportId : UInt8 = 2
        guard let components = color.components else {
            print("Color unpack failed")
            return
        }
        print("Components=\(components)")

        let red = components[0]
        let green = components[1]
        let blue = components[2]

        /*
        let xmax = max(r, g, b)
        let xmin = min(r, g, b)
        let v = xmax

        let c = xmax - xmin
        let l = v - c / 2
        let h: UInt16
        if c == 0 {
          h = 0
        } else if v == r {
          h = UInt16(60 * (0 + (g - b) / c))
        } else if v == g {
          h = UInt16(60 * (2 + (b - r) / c))
        } else {
          h = UInt16(60 * (4 + (r - g) / c))
        }

        let sv: CGFloat
        if v == 0 {
            sv = 0
        } else {
            sv = c / v
        }

        let sl: CGFloat
        if l == 0 || l == 1 {
            sl = 0
        } else {
            sl = (v - l) / min(l, 1 - l)
        }
         */

        let (h, s, b) = rgbToHue(r: red, g: green, b: blue)

        let bytes2 : [UInt8] = [1, 0, UInt8(UInt16(h) & 0xff), UInt8(UInt16(h) >> 8), UInt8(s * 100), UInt8(b * 100)]
        self.output(Data(bytes2))
    }

@objc func initUsb() {
    let deviceMatch = [kIOHIDProductIDKey: productId, kIOHIDVendorIDKey: vendorId]
    let managerRef = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

    IOHIDManagerSetDeviceMatching(managerRef, deviceMatch as CFDictionary?)
    IOHIDManagerScheduleWithRunLoop(managerRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    IOHIDManagerOpen(managerRef, 0)

    let matchingCallback : IOHIDDeviceCallback = { inContext, inResult, inSender, inIOHIDDeviceRef in
        let this : Blink1 = Unmanaged<Blink1>.fromOpaque(inContext!).takeUnretainedValue()
        this.connected(inResult, inSender: inSender!, inIOHIDDeviceRef: inIOHIDDeviceRef)
    }

    let removalCallback : IOHIDDeviceCallback = { inContext, inResult, inSender, inIOHIDDeviceRef in
        let this : Blink1 = Unmanaged<Blink1>.fromOpaque(inContext!).takeUnretainedValue()
        this.removed(inResult, inSender: inSender!, inIOHIDDeviceRef: inIOHIDDeviceRef)
    }

    let this = Unmanaged.passRetained(self).toOpaque()
    IOHIDManagerRegisterDeviceMatchingCallback(managerRef, matchingCallback, this)
    IOHIDManagerRegisterDeviceRemovalCallback(managerRef, removalCallback, this)

    NotificationCenter.default.addObserver(forName: Notification.Name("glove80colorChanged"), object: nil, queue: nil) { notification in
        print("Got notification")
        guard let info = notification.userInfo else { return }
        let color: CGColor = info["color"] as! CGColor
        print("Sending color: \(color)")
        self.sendColor(color)
    }

    RunLoop.current.run()
}

}
