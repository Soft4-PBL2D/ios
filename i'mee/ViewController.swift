//
//  ViewController.swift
//  i'mee
//
//  Created by pianix on 2016/11/07.
//  Copyright © 2016年 PARM. All rights reserved.
//

import UIKit
import Photos
import CoreLocation

class ViewController: UIViewController {
    
    @IBAction func tutob(sender: AnyObject) {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            
            switch(status){
            case .Authorized:
                print("ライブラリアクセス：許可済み")
                
            case .Denied:
                print("ライブラリアクセス：拒否")
                
            case .NotDetermined:
                print("ライブラリアクセス：未選択")
                
            case .Restricted:
                print("ライブラリアクセス：制限")
            }
        }
        

        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier( "WKV" ) as! UIViewController
        self.presentViewController( targetViewController, animated: true, completion: nil)
        
    }
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        print("プログレス")
        super.viewDidLoad()
        
        
        //初回起動判定
        let ud = NSUserDefaults.standardUserDefaults()
        print(ud.boolForKey("firstLaunch"))
        if ud.boolForKey("firstLaunch") {
            
            // 初回起動時の処理
            print("初期起動")
            
            //2回目以降の起動では「firstLaunch」のkeyをfalseに
            ud.setBool(false, forKey: "firstLaunch")
        }
        
        
        

        
    }

    
    //Notworking
    func navigationBarAndStatusBarHidden(hidden: Bool, animated: Bool)
    {
        if let nv = navigationController {
            
            if nv.navigationBarHidden == hidden {
                return
            }
            
            let application = UIApplication.sharedApplication()
            
            if (hidden) {
                // 隠す
                nv.setNavigationBarHidden(hidden, animated: animated)
                application.setStatusBarHidden(hidden, withAnimation: animated ? .Slide : .None)
            } else {
                // 表示する
                application.setStatusBarHidden(hidden, withAnimation: animated ? .Slide : .None)
                nv.setNavigationBarHidden(hidden, animated: animated)
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    

}

