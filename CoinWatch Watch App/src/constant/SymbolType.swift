//
//  SymbolType.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/10/4.
//

/**
 symbol的类型
 */
enum SymbolType:String,Codable, CaseIterable {
    /**
     现货
     */
    case spot
    
    /**
     合约
     */
    case contract
    
    static func generateStr(str:String) -> SymbolType? {
        if str == "spot" {
            return .spot
        }
        if str == "contract" {
            return .contract
        }
        return nil
    }
    
    func next() -> SymbolType {
        let allCases = SymbolType.allCases
        let currentIndex = allCases.firstIndex(of: self)!
        let nextIndex = allCases.index(after: currentIndex)
        return nextIndex < allCases.endIndex ? allCases[nextIndex] : allCases.first!
    }
}
