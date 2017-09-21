
//
//  File.swift
//  HackWinds
//
//  Created by Matthew Iannucci on 9/21/17.
//  Copyright © 2017 Rhodysurf Development. All rights reserved.
//

import Foundation
import WatchConnectivity


class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
    private override init() {
        super.init()
    }
    
    private let session: WCSession = WCSession.default()
    
    func startSession() {
        session.delegate = self
        session.activate()
    }
    
    @available(watchOS 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // TODO
    }
}

// MARK: User Info
// use when your app needs all the data
// FIFO queue
extension WatchSessionManager {
    
    // Receiver
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        
        // handle receiving user info
        DispatchQueue.main.async() { [weak self] in
            // TODO: Update what needs to be updated
            NSLog(userInfo.keys.first as String!)
        }
    }
    
}
