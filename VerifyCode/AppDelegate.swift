//
//  AppDelegate.swift
//  VerifyCode
//
//  Created by soliduSystem on 13/03/23.
//

import UIKit
import PusherSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PusherDelegate {
    
    // You must retain a strong reference to the Pusher instance
    var pusher: Pusher!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let options = PusherClientOptions(
            host: .cluster("mt1")
        )
        
        pusher = Pusher(
            key: "8a62714e691f90050161",
            options: options
        )
        
        
        pusher.delegate = self
        
        let channel = pusher.subscribe("qrchannel")
        
        let _ = pusher.bind(eventCallback: { (event: PusherEvent) in
                   var message = "Received event: '\(event.eventName)'"

                   if let channel = event.channelName {
                       message += " on channel '\(channel)'"
                   }
                   if let userId = event.userId {
                       message += " from user '\(userId)'"
                   }
                   if let data = event.data {
                       message += " with data '\(data)'"
                   }

                   print(message)
               })
        
        // bind a callback to handle an event
        let channerlbind = channel.bind(eventName: "EventQr", eventCallback: { (event: PusherEvent) in
            
            if let data = event.data {
                // you can parse the data as necessary
                print(data)
            }
            
            let myOData = [
                "data": [
                    "rol": "Admin",
                    "token": "Toeken",
                    "hora": "hola"
                ]
            ]
            
            channel.trigger(eventName: "EventQr", data: myOData)
        })
        
        pusher.connect()
        
        return true
    }

    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}
