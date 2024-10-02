//
//  BinanceApiRequest.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/23.
//


import Foundation
import Alamofire
import SwiftyJSON
import CryptoKit

public class BinanceApiRequest {
    
    static func binanceApiRequest(
        method: HTTPMethod = .get,
        url: String,
        ipWeight: Int,
        body:[String:Any?]? = [:],
        parameters: [String: Any?]? = [:],
        success : ((JSON) -> Void)? = nil,
        failure: ((BinanceAPIError) -> Void)? = nil,
        cryptoInfo: CryptoInfo? = nil,
        isSignature: Bool
    ) -> Void{
        //TODO 计算更新ipWeight
        
        
        //必要参数
        var result:(url:String, body:[String:Any])? = nil
        if isSignature {
            result = signatureArgsResolve(
                method: method,
                url: url,
                body: body,
                parameters: parameters
            )
        } else {
            result = normalArgsResolve(
                method: method,
                url: url,
                body: body,
                parameters: parameters
            )
        }
      
        print("网络请求 \(String(describing: result))")
                
        request(
            method:method,
            url: result?.url ?? "",
            body: result?.body,
            successCall: success,
            failureCall: { error in
                print("网络请求失败，url\(result?.url ?? "")，error\(error)")
                if let failure = failure {
                    failure(error)
                }
            },
            isLoading: nil
        )
    }
    
    static func normalArgsResolve(
        method: HTTPMethod = .get,
        url:String,
        body:[String:Any?]?,
        parameters: [String: Any?]?
    ) -> (url:String, body:[String:Any]) {
        var noNilParames:[String: Any?] = [:]
        parameters?.forEach({ (key: String, value: Any?) in
            if value != nil {
                noNilParames[key] = value
            }
        })
        
        var noNilBody:[String: Any] = [:]
        body?.forEach({ (key: String, value: Any?) in
            if value != nil {
                noNilBody[key] = value
            }
        })
        
        let result  = signatureRequest(body: body, parameters: noNilParames)
        let queryString = result.queryString ?? ""
        let requestURL = url + "?" + queryString
        
        return (url: requestURL, body: noNilBody)
    }
    
    
    static func signatureArgsResolve(
        method: HTTPMethod = .get,
        url:String,
        body:[String:Any?]?,
        parameters: [String: Any?]?
    ) -> (url:String, body:[String:Any]) {
        var allParames:[String: Any?] = [
            "timestamp": DateUtil.dateToTimestamp(date: Date()),
            "recvWindow": 10000
        ]
        parameters?.forEach({ (key: String, value: Any?) in
            if value != nil {
                allParames[key] = value
            }
        })

        
        let result  = signatureRequest(body: body, parameters: allParames, SK: CryptoInfo.getSK())
        let queryString = result.queryString ?? ""
        let signature = result.signature ?? ""
                
        var requestURL = url + "?" + queryString
        
        var signatureBody:[String: Any] = [:]
        body?.forEach({ (key: String, value: Any?) in
            if value != nil {
                signatureBody[key] = value
            }
        })
        
        if method == .get {
            requestURL += "&signature=" + signature
        }
        if method == .post {
            signatureBody["signature"] = signature
        }
        
        return (url: requestURL, body: signatureBody)
    }
    
    
    static func signatureRequest(
        body:[String:Any?]? = [:],
        parameters: [String: Any?]? = [:],
        SK: String? = nil
    ) -> (signature: String?, queryString: String?) {
        var queryString = ""
        //签名
        var sionedString = ""
        if let body = body { //body
            var str = ""
            for (key, value) in body {
                if let value = value {
                    str = str + "&\(key)=\(String(describing: value))"
                }
            }
            if !str.isEmpty {
                str.removeFirst()
            }
            sionedString = sionedString + str
        }
        
        if let parameters = parameters { //query
            var str = ""
            for (key, value) in parameters {
                if let value = value {
                    str = str + "&\(key)=\(String(describing: value))"
                }
            }
            if !str.isEmpty {
                str.removeFirst()
            }
            sionedString = sionedString + str
            queryString = str
        }
        
        if let sk = SK {
            return (hmacSHA256(message: sionedString, key: sk), queryString)
        }
        
        return ("", queryString)
    }
  
    
    static func hmacSHA256(message: String, key: String) -> String {
        // 将字符串转换为 Data
        let keyData = Data(key.utf8)
        let messageData = Data(message.utf8)

        // 创建 HMAC-SHA256 签名
        let hmac = HMAC<SHA256>.authenticationCode(for: messageData, using: SymmetricKey(data: keyData))
        
        // 将结果转换为十六进制字符串
        return hmac.map { String(format: "%02hhx", $0) }.joined()
    }
    

    
    static func request(method: HTTPMethod = .get,
                 url: String,
                 body:[String: Any?]? = nil,
                 parameters: [String: Any?]? = nil,
                 successCall : ((JSON) -> Void)? = nil,
                 failureCall: ((BinanceAPIError) -> Void)? = nil,
                 isLoading:Bool? = nil
    ) {
        
        if isLoading == true {
            
        }
                
        let headers:HTTPHeaders =  [
            "Content-Type":"application/json;charset=UTF-8",
            "Accept":"application/json",
            "X-MBX-APIKEY": CryptoInfo.getAK()
        ]
        
        var nonNilBody:[String:Any] = [:]
        if let body = body {
            nonNilBody = body.compactMapValues { $0 }
        }
        
        print("body - \(nonNilBody)")
        AF.request(
            url,
            method: method,
            parameters: nonNilBody.isEmpty ? nil : nonNilBody,
            encoding:JSONEncoding.default,
            headers: headers
        )
        .validate()
        .responseData { res in
            switch res.result {
            case .success(let value) :
//                print("url -- \(url), request succeess")
                let json = try? JSON(data: value)
                if successCall != nil {
                    successCall!(json!)
                }
            case .failure(let error):
                print("url -- \(url), request error \(error),   \n\(res)")
                let eCode = res.response?.statusCode ?? 500
                var errorType = BinanceAPIError.ERROR_UNKNOW
                if eCode == 403 {
                    errorType = .ERROR_WAF
                } else if eCode == 409 {
                    errorType = .ERROR_CANCEL_REPLACE
                } else if eCode == 429 {
                    errorType = .ERROR_REQUEST_LIMIT
                } else if eCode/100 == 5 {
                    errorType = .ERROR_BINANCE_SERVER
                } else if eCode/100 == 4 {
                    errorType = BinanceAPIError.ERROR_REQUEST
                }
                if (failureCall != nil) {
                    failureCall!(errorType)
                }
            }
        }
    }

}



enum BinanceAPIError: String {
    case ERROR_UNKNOW = "未知错误"
    case ERROR_REQUEST = "4xx 错误的请求内容、行为、格式"
    case ERROR_WAF = "403 违反WAF限制(Web应用程序防火墙)"
    case ERROR_CANCEL_REPLACE = "409 重新下单(cancelReplace)的请求部分成功。(比如取消订单失败，但是下单成功了)"
    case ERROR_REQUEST_LIMIT = "429 警告访问频次超限，即将被封IP。"
    case ERROR_BINANCE_SERVER = "5XX Binance服务侧的问题。"
}


enum BaseURL: String {
    
    case PUBLIC_DATA_API = "https://data-api.binance.vision" //于仅发送公开市场数据的 API
    case NORMAL_API_1 = "https://api.binance.com"
    case NORMAL_API_2 = "https://api-gcp.binance.com"
    
    case PERFORMANCE_API_1 = "https://api1.binance.com"
    case PERFORMANCE_API_2 = "https://api2.binance.com"
    case PERFORMANCE_API_3 = "https://api3.binance.com"
    case PERFORMANCE_API_4 = "https://api4.binance.com"
}
