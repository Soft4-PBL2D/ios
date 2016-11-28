//
//  WebViewController.swift
//  i'mee
//
//  Created by pianix on 2016/11/07.
//  Copyright © 2016年 PARM. All rights reserved.
//

import UIKit
import WebKit
import SystemConfiguration
import Photos

class WebViewController: UIViewController, UIWebViewDelegate{


    var _webkitview: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._webkitview = WKWebView()
        self.view = self._webkitview!
        
        //let initialurl = NSURL(string: "https://imee.amfys.net:8443/login.php")
        let initialurl = NSURL(string: "http://192.168.41.21:3000/")
        let initial_request = NSURLRequest(URL: initialurl!,
                                           cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData,
                                           timeoutInterval: 6.0)
        self._webkitview!.loadRequest(initial_request)
        
        
        
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
    }
    
    


}
