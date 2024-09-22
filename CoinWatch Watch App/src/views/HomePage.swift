//
//  HomePage.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import Foundation
import SwiftUI


struct HomePage: View {
    @State private var selection = 0
    var body: some View {
        // 定义一个 Button，点击时触发 Alert
        TabView(selection: $selection) {
            // 第一个标签页
            AccountGeneralPage()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(0) // 与selection绑定，表示这是第一个标签页
            
            // 第二个标签页
            Text("Coin Info")
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(1) // 与selection绑定，表示这是第二个标签页
            
            Text("社区")
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(1) // 与selection绑定，表示这是第二个标签页
            
            Text("我的")
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(1) // 与selection绑定，表示这是第二个标签页
        }
        .accentColor(.blue) // 设置标签栏的强调色
    }
}


#Preview {
    HomePage()
}
