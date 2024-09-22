//
//  CoinImage.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/22.
//

import SwiftUI
import Kingfisher

struct CoinImage: View {
    var imageUrl: String
    
    var body: some View {
        KFImage(URL(string: imageUrl))
        // 调整渲染模式
            .renderingMode(.original)
        // 也可以在图像加载时展示进度指示器
            .placeholder {
                ProgressView()
            }
            .onSuccess { result in
                print("\(result.image) - \(result.cacheType)")
            }
            .onFailure { error in
                print("\(error)")
            }
            .resizable()
            .scaledToFit()
        
//            .blur(radius: 2)
    }
}
