//
//  LoginUtil.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import Foundation
import KeychainSwift

class LoginUtil {
    static let keyChain: KeychainSwift = KeychainSwift()
    
    static func login(username username: String, password password: String, callback: (Bool) -> Void) {
        //TODO 请求后端登录
        
        callback(true)
    }
    
    static func isLogin() -> Bool {
        return true
    }
    
    static func saveUserLoginInfo(username: String="", paassword: String="") {
        LoginUtil.keyChain.set(username, forKey: SystemConstant.USERNAME_KEY)
        LoginUtil.keyChain.set(paassword, forKey: SystemConstant.PASSWORD_KEY)
    }
    
    static func loadLoginInfo() -> [String?:String?]{
        let username = LoginUtil.keyChain.get(SystemConstant.USERNAME_KEY)
        let password = LoginUtil.keyChain.get(SystemConstant.PASSWORD_KEY)
        return [
            SystemConstant.USERNAME_KEY: username,
            SystemConstant.PASSWORD_KEY: password
        ]
    }
}
