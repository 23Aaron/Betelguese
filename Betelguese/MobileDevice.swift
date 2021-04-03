//
//  MobileDevice.swift
//  Betelguese
//
//  Created by Aaron Kingsley on 03/04/2021.
//  Copyright © 2021 23 Aaron. All rights reserved.
//

import Foundation

enum MDError: mach_error_t {
    case ok = 0
}

enum AMDeviceNotificationCallbackMessage: UInt32 {
    case connected = 1
    case disconnected = 2
    case unknown = 3
}

class MobileDeviceHelper {

    static let deviceDidConnectNotification = Notification.Name(rawValue: "MobileDeviceDidConnectNotification")
    static let deviceDidDisconnectNotification = Notification.Name(rawValue: "MobileDeviceDidDisconnectNotification")

    static var deviceConnected: UnsafeMutablePointer<am_device>?
    static var deviceName: String?
    static var deviceFirmware: String?

    static func subscribeForDeviceNotifications() {
        var notificationPointer: UnsafeMutablePointer<am_device_notification>? = UnsafeMutablePointer.allocate(capacity: 1)
        notificationPointer?.pointee = am_device_notification()

        let callback: am_device_notification_callback = { infoPointer, _ in
            if let info = infoPointer?.pointee {
                MobileDeviceHelper.deviceNotificationReceived(info: info)
            }
        }
        AMDeviceNotificationSubscribe(callback, 0, 0, nil, &notificationPointer)
    }

    static func handleAppWillTerminate() {
        disconnect()
    }

    fileprivate static func deviceNotificationReceived(info: am_device_notification_callback_info) {
        switch AMDeviceNotificationCallbackMessage(rawValue: info.msg) ?? .unknown {
        case .connected:
            if info.dev != deviceConnected {
                disconnect()
                connect(device: info.dev)
            }
            break

        case .disconnected:
            if info.dev == deviceConnected {
                disconnect()
            }
            break

        case .unknown: break
        }
    }

    private static func connect(device: UnsafeMutablePointer<am_device>) {
        deviceConnected = device
        AMDeviceRetain(device)

        let ok = MDError.ok.rawValue
        if AMDeviceConnect(device) == ok,
           AMDeviceIsPaired(device) == 1,
           AMDeviceValidatePairing(device) == ok,
           AMDeviceStartSession(device) == ok {
            deviceName = AMDeviceCopyValue(device, 0, "DeviceName" as CFString).takeRetainedValue() as String
            deviceFirmware = AMDeviceCopyValue(device, 0, "ProductVersion" as CFString).takeRetainedValue() as String
            NotificationCenter.default.post(name: self.deviceDidConnectNotification, object: nil)
        } else {
            NSLog("MobileDevice connection failed?")
        }
    }

    private static func disconnect() {
        guard let device = deviceConnected else {
            return
        }

        AMDeviceRelease(device)
        AMDeviceStopSession(device)
        AMDeviceDisconnect(device)
        deviceConnected = nil

        NotificationCenter.default.post(name: self.deviceDidDisconnectNotification, object: nil)
    }

}
