//
//  UserInfo.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/3.
//

import Foundation

@Observable
class UserInfo {
    
    static var sharedInstance:UserInfo = UserInfo()
    
    /**
     账户是否可用
     */
    var usable: Bool = false
    
    /**
     用户名
     */
    var username:String? = nil
    
    /**
     密码
     */
    var password:String? = nil
    
    /**
     token
     */
    var token: String? = nil
    
    /**
     邮箱
     */
    var Email: String? = nil
    
    
    private init() {
        
    }
}
