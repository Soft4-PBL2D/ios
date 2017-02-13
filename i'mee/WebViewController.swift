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

class WebViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate{


    var _webkitview: WKWebView?
    var webview : WKWebView?
    var callcount = 0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let activitiyViewController = ActivityViewController(message: "接続中")
        presentViewController(activitiyViewController, animated: false, completion: nil)
        print("didload")
        //  デバイスのCGRectを取得
        let deviceBound : CGRect = UIScreen.mainScreen().bounds
        
        //let initialurl = NSURL(string: "https://imee.amfys.net:8443/login.php")
        let initialurl = NSURL(string: "http://192.168.41.21:3000/")

        //  WKWebView
        //ReloadIgnoringLocalAndRemoteCacheData
        //UseProtocolCachePolicy
        self.webview = WKWebView(frame: CGRectMake(0, 20, deviceBound.size.width, deviceBound.size.height - 20))
        self.webview?.loadRequest(NSURLRequest(URL: initialurl!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 4.0))
        self.view.addSubview(self.webview!)
        self.webview!.navigationDelegate = self
        self.webview!.allowsLinkPreview = false
        
       
        
        
    }

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
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
    

    /*func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(callcount)
        if(callcount == 0){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            callcount = 1
            let activitiyViewController = ActivityViewController(message: "サーバー接続中")
            presentViewController(activitiyViewController, animated: false, completion: nil)
        }
        
    }*/
    
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        
        dismissViewControllerAnimated(false, completion: nil)
        print("エラー")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        
        print(error.code)
        
        if error.code == -1001 { // TIMED OUT:
            
            print("接続タイムアウト")
            
            let alertController = UIAlertController(title: "サーバーからの応答がありません", message: "I'meeサーバーへの接続ができませんでした。端末がオンラインか、電波環境の良いところかどうかをお確かめください。", preferredStyle: .Alert)
            //はいボタン
            let defaultAction:UIAlertAction = UIAlertAction(title: "はい",
                                                            style: UIAlertActionStyle.Default,
                                                            handler:{
                                                                (action:UIAlertAction!) -> Void in
                                                                let targetView: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier( "tuto" )
                                                                self.presentViewController( targetView as! UIViewController, animated: true, completion: nil)
            })
            
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
            
            
                       
        }else if error.code == -1009 { // TIMED OUT:
            
            print("接続タイムアウト")
            
            let alertController = UIAlertController(title: "接続に失敗しました", message: "I'meeサーバーへの接続ができませんでした。端末がオンラインか、電波環境の良いところかどうかをお確かめください。", preferredStyle: .Alert)
            //はいボタン
            let defaultAction:UIAlertAction = UIAlertAction(title: "はい",
                                                            style: UIAlertActionStyle.Default,
                                                            handler:{
                                                                (action:UIAlertAction!) -> Void in
                                                            print("ok")
                                                                
            })
            
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
            
            
            
        }
        
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
    
    

    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //let activitiyViewController = ActivityViewController(message: "接続中")
        //presentViewController(activitiyViewController, animated: true, completion: nil)
    }
    
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    
}
