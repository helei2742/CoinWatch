//
//  JsonUtil.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/10/4.
//
import SwiftUI

class JsonUtil {
    
    static func  objToJSONStr(obj:Codable) -> String? {
        // 使用 JSONEncoder 将对象编码为 JSON 数据
          let encoder = JSONEncoder()
          encoder.outputFormatting = .prettyPrinted // 可选：格式化 JSON 输出
          
          do {
              let jsonData = try encoder.encode(obj) // 将对象编码为 JSON 数据
               
              if let jsonString = String(data: jsonData, encoding: .utf8) { // 将 JSON 数据转换为字符串
                  return jsonString
              }
          } catch {
              print("Failed to encode object: \(error)")
          }
        return nil
    }
}
