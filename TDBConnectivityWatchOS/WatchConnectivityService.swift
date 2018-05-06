//
//  WatchConnectivityService.swift
//  TDBConnectivityWatchOS
//
//  Created by Tim Beals on 2018-05-04.
//  Copyright © 2018 Tim Beals. All rights reserved.
//

import UIKit
import WatchConnectivity

//MARK: WatchConnectivityService protocol
public protocol WatchConnectivityServiceDelegate {
    func reply(to message: [String: Any], replyHandler: @escaping([String: Any]) -> ())
}

public class WatchConnectivityService: NSObject {
    
    private override init() {
        super.init()
        
    }
    public static var shared = WatchConnectivityService()
    
    public var delegate: WatchConnectivityServiceDelegate?
    
    public var session: WCSession = WCSession.default
    
    public func activate() {
        if (WCSession.isSupported()) {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        //0: notActivated, 1: inactive, 2: activated
        print("WCS Status: \(WCSession.default.activationState.rawValue)")
        print("WCS Is Reachable: \(WCSession.default.isReachable)")
    }
    
    // Send a message immediately, no reply
    public func sendMessage(identifier: String, payload: [String: Any]) {
        var userInfo: [String: Any] = [UserInfoKey.channel: Channel.sendMessage.rawValue,
                                       UserInfoKey.identifier: identifier,
                                       UserInfoKey.payload: payload,
                                       UserInfoKey.phrase: Phrase.sent.rawValue]
        
        WCSession.default.sendMessage(userInfo, replyHandler: nil) { (error) in
            userInfo[UserInfoKey.error] = error
            self.postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
        }
    }
    
    // Send a message immediately with reply
    public func sendMessage(identifier: String, payload: [String: Any], replyHandler: @escaping([String: Any]) -> ()) {
        
        var userInfo: [String: Any] = [UserInfoKey.channel: Channel.sendMessage.rawValue,
                                       UserInfoKey.identifier: identifier,
                                       UserInfoKey.payload: payload,
                                       UserInfoKey.phrase: Phrase.sent.rawValue]
        
        self.postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
        
        WCSession.default.sendMessage(userInfo, replyHandler: { replyMessage in
            
            replyHandler(replyMessage)
            self.postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
            
        }, errorHandler: { error in
            print("WCS ERROR HANDLER: \(error.localizedDescription)")
            userInfo[UserInfoKey.error] = error
            self.postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
        })
    }
    
    // Post a notification on the main thread asynchronously.
    fileprivate func postNotificationOnMainQueue(name: NSNotification.Name, object: Any? = nil,
                                                 userInfo: [AnyHashable : Any]? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
        }
    }
}

//MARK: WCSessionDelegate methods
extension WatchConnectivityService : WCSessionDelegate {
    
    open func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
    
    
    // Called when a message is received and the peer doesn't need a response.
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        let identifier = message[UserInfoKey.identifier] ?? "received"
        let payload = message[UserInfoKey.payload] ?? [:]
        
        let userInfo: [String : Any] = [UserInfoKey.channel: Channel.sendMessage.rawValue,
                                        UserInfoKey.phrase: Phrase.received.rawValue,
                                        UserInfoKey.identifier: identifier,
                                        UserInfoKey.payload: payload]
        
        postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
    }
    
    
    // Called when a message is received and the peer needs a response.
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any],
                        replyHandler: @escaping ([String : Any]) -> Void) {
        
        self.delegate?.reply(to: message, replyHandler: { (response) in
            
            let identifier = response[UserInfoKey.identifier] ?? "response"
            let payload = response[UserInfoKey.payload] ?? [:]
            
            let userInfo: [String: Any] = [UserInfoKey.channel: Channel.sendMessage.rawValue,
                                           UserInfoKey.payload: payload,
                                           UserInfoKey.identifier: identifier,
                                           UserInfoKey.phrase: Phrase.replied.rawValue]
            
            self.postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
            replyHandler(userInfo)
        })
        replyHandler([:])
    }
    
    #if os(iOS)
    open func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }
    
    open func sessionDidDeactivate(_ session: WCSession) {
        //
    }
    #endif
}
