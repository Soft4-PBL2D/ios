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
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.redColor()
        // Do any additional setup after loading the view, typically from a nib.
        
        //ライブラリーへの権限を要求
        
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

