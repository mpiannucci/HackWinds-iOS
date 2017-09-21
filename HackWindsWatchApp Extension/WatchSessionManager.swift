
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
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        // handle receiving user info
        DispatchQueue.main.async() { () in
            // TODO: Update what needs to be updated
            let groupDefaults = UserDefaults.init(suiteName: "group.com.mpiannucci.HackWinds")
            groupDefaults?.set(userInfo["DefaultBuoyLocation"], forKey: "DefaultBuoyLocation")
            groupDefaults?.synchronize()
        }
    }
}
