//
//  SystemFont.swift
//  CoinIWatch
//
//  Created by 何磊 on 2024/9/21.
//

import Foundation
import SwiftUI

extension Font {
    static func largeFont() -> Font {
        return
            Font.custom("PingFang", size: 20).weight(.bold)
    }
    
    static func defaultFont() -> Font {
        return
            Font.custom("PingFang", size: 12).weight(.bold)
    }
    
    static func numberFont_0() -> Font {
        return
            Font.custom("PingFang", size: 25).weight(.bold)
        
    }
    
    static func littleFont() -> Font {
        return .custom("", size: 8).weight(.ultraLight)
    }
}

