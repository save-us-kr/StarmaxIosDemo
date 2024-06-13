//
//  AppDelegate.swift
//  SDKTest
//
//  Created by wangjun on 2019/11/12.
//  Copyright © 2019 wangjun. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func SVProgressHUDConfig() {
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(0.05)
        SVProgressHUD.setMaximumDismissTimeInterval(2.5)
//        SVProgressHUD.setMinimumSize(CGSize(width: kScaleWidth(95), height: kScaleHeight(85)))
//        SVProgressHUD.setOffsetFromCenter(UIOffset.init(horizontal: kScreenW/2, vertical: kScreenH/2))
    }
    
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let main = ViewController()
        let navi = UINavigationController.init(rootViewController: main)
        let tab = UITabBarController.init()
        tab.viewControllers = [navi]
        window?.rootViewController = tab
        window?.makeKeyAndVisible()
        SVProgressHUDConfig()
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {    
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


