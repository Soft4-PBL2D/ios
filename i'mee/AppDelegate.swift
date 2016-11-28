//
//  AppDelegate.swift
//  i'mee
//
//  Created by pianix on 2016/11/07.
//  Copyright © 2016年 PARM. All rights reserved.
//

import UIKit
import SystemConfiguration

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }
    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        // ここから
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if CheckReachability("aaa") {
            print("接続が確認されました")

        } else {
            print("接続エラー")
            
            let alertController = UIAlertController(title: "ネットワークに接続してください", message: "I'meeはオフラインでは動作しません", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "了解", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
        
        // ここまで
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
    
    

    func CheckReachability(host_name:String)->Bool{
        
        let reachability = SCNetworkReachabilityCreateWithName(nil, host_name)!
        var flags = SCNetworkReachabilityFlags.ConnectionAutomatic
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // NSUserDefaults のインスタンス取得
        let ud = NSUserDefaults.standardUserDefaults()
        // デフォルト値の設定
        let dic = ["firstLaunch": true]
        ud.registerDefaults(dic)
        
        return true
        
    }
    
    
    
    
    
    


}





