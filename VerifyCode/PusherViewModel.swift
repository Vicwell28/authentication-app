//
//  PusherViewModel.swift
//  VerifyCode
//
//  Created by soliduSystem on 15/04/23.
//

import Foundation
import PusherSwift


class PusherViewModel: PusherDelegate {
    
    private var pusher: Pusher!
    public var delegate: PusherBindEventDelegate?
    
    init(pusher: Pusher, delegate: PusherBindEventDelegate? = nil) {
        self.pusher = pusher
        self.delegate = delegate
    }
    
    public func setUp() {
        
       pusher.delegate = self
        
        let channel = pusher.subscribe("qrchannel")
        
        pusher.connect()
        
        let _ = channel.bind(eventName: "EventQr", eventCallback: { (event: PusherEvent) in
            self.delegate?.didPusherDidEvent(event: event)
        })
    }
    
}

protocol PusherBindEventDelegate {
    func didPusherDidEvent(event: PusherEvent) -> Void
}
