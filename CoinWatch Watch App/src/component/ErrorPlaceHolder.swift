//
//  ErrorPlaceHolder.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/10/4.
//

import SwiftUI

struct ErrorPlaceholderView: View {
    var errorMessage: String
    
    var body: some View {
        
        VStack(spacing: 20) {
            // 错误图标
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.red)
            
            // 错误消息
            Text(errorMessage)
                .font(.defaultFont())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}
