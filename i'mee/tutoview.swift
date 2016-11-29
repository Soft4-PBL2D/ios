//
//  tutoview.swift
//  i'mee
//
//  Created by pianix on 2016/11/29.
//  Copyright © 2016年 PARM. All rights reserved.
//

import Foundation
import UIKit
import Photos
import CoreLocation

class tutoview :UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.greenColor()
        
        
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
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
    
}
