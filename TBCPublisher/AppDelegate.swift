//
//  AppDelegate.swift
//  TBCPublisher
//
//  Created by Qingqing Liu on 4/24/20.
//  Copyright © 2020 Qingqing Liu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let convo = SampleData.shared.getConversations(count: 1)[0]
        window?.rootViewController = UINavigationController(rootViewController: CommunityPublisherViewController(conversation: convo))
        window?.makeKeyAndVisible()
                
        return true
    }
}
