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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //  デバイスのCGRectを取得
        let deviceBound : CGRect = UIScreen.mainScreen().bounds
        
        //let initialurl = NSURL(string: "https://imee.amfys.net:8443/login.php")
        let initialurl = NSURL(string: "http://192.168.41.21:3000/")

        //  WKWebView
        
        self.webview = WKWebView(frame: CGRectMake(0, 20, deviceBound.size.width, deviceBound.size.height - 20))
        self.webview?.loadRequest(NSURLRequest(URL: initialurl!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 6.0))
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
    
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        
        if error.code == -1001 { // TIMED OUT:
            
            print("接続タイムアウト")
            let alertController = UIAlertController(title: "タイムアウトしました", message: "I'meeサーバーへの接続がタイムアウトしました。", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
            webView.reload()
            
        } else if error.code == -1003 { // SERVER CANNOT BE FOUND
            
            print("サーバーが見つからない")
            let alertController = UIAlertController(title: "サーバーに接続できませんでした", message: "しばらく時間をおいてアクセスしてください", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
        } else if error.code == -1100 { // URL NOT FOUND ON SERVER
            
            print("URLが見つからない")
            let alertController = UIAlertController(title: "リクエストを処理できませんでした", message: "URLが見つかりません", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
        }
    }
    
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        
        if CheckReachability("zzzz3000") {
            decisionHandler(WKNavigationActionPolicy.Allow)
            print("接続OK")
        } else {
            print("接続NG")
            decisionHandler(WKNavigationActionPolicy.Cancel)
            let alertController = UIAlertController(title: "ネットワークに接続してください", message: "I'meeはオンラインで動作します", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
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
    
    


}
