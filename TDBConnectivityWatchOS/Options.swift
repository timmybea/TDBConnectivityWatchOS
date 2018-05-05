//
//  Options.swift
//  TDBConnectivityWatchOS
//
//  Created by Tim Beals on 2018-05-04.
//  Copyright © 2018 Tim Beals. All rights reserved.
//

import Foundation

// Custom notifications.
// Posted when Watch Connectivity activation or reachibility status is changed,
// or when data is received or sent. Clients observe these notifications to update the UI.

public extension Notification.Name {
    public static let dataDidFlow = Notification.Name("DataDidFlow")
    public static let activationDidComplete = Notification.Name("ActivationDidComplete")
    public static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
}

// Constants to organize and access the information in the notication userInfo dictionary.
//
public struct UserInfoKey {
    public static let channel = "channel" //String
    public static let identifier = "identifier" //String
    public static let phrase = "phrase" //String
    public static let payload = "payload" //[String: Any]
    public static let error = "error" //Error
    public static let activationStatus = "ectivationStatus"
    public static let reachable = "reachable"
    public static let fileURL = "fileURL"
}

// Constants to identify the Watch Connectivity methods, also used as user-visible strings in UI.
//
public enum Channel: String {
    case updateAppContext = "UpdateAppContext"
    case sendMessage = "SendMessage"
    case sendMessageData = "SendMessageData"
    case transferUserInfo = "TransferUserInfo"
    case transferFile = "TransferFile"
    case transferCurrentComplicationUserInfo = "TransferCurrentComplicationUserInfo"
}

// Constants to identify the phrases of a Watch Connectivity communication,
// also shown in the logs on the iOS side.
//
public enum Phrase: String {
    case updated = "Updated"
    case sent = "Sent"
    case received = "Received"
    case replied = "Replied"
    case transferring = "Transferring"
    case finished = "Finished"
    case failed = "Failed"
}
