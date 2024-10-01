//
//  Test.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/30.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello, Watch!")
            }
            .toolbar {
                // 添加一个按钮在左边
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        // 左侧按钮的操作
                        print("Cancel button tapped")
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                
                // 添加一个按钮在右边
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        // 右侧按钮的操作
                        print("Done button tapped")
                    }) {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
