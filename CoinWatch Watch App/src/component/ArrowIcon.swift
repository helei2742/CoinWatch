//
//  ArrowIcon.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/21.
//

import SwiftUI

struct ArrowIcon: View {
    var judge: Double
    
    var body: some View {
        VStack{
            if judge == 0 {
                Image("arrow.nochange")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit) // 保持宽高比，但通常对于系统图标来说不是必需的
                    .frame(width: 13, height: 13)
            }
            else if judge > 0 {
                Image("arrow.up")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit) // 保持宽高比，但通常对于系统图标来说不是必需的
                    .frame(width: 13, height: 13)
            }
            else if judge < 0 {
                Image("arrow.down")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit) // 保持宽高比，但通常对于系统图标来说不是必需的
                    .frame(width: 13, height: 13)
            }
            Spacer()
        }
    }
}

#Preview {
    ArrowIcon(judge: 0)
    ArrowIcon(judge: 1)
    ArrowIcon(judge: -1)
}
