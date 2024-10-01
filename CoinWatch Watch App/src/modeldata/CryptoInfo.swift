//
//  CryptoInfo.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/23.
//

/**
 账号加密的信息
 */
struct CryptoInfo {
    private static let shareInstance: CryptoInfo = CryptoInfo()
    
    var apiKey:String = "QtC1Sy0IflVNg7yoQwUkZHsyhuPONCwGhfz1oLUBS1J9i47y3bRUS9euGig8iycL" //放请求头
    
    var secretKey:String = "9zpXD991bjGGtU6lHEX9VCs9YX2Du7gW3fCBE9SPNCz177yhCFZ74rN64I4wGRrh" //加密key
    
    private init(){
        
    }
    
    static func getAK() -> String {
        return shareInstance.apiKey
    }
    
    
    static func getSK() -> String {
        return shareInstance.secretKey
    }
}
