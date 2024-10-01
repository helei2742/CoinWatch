//
//  NotificationBar.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/28.
//

import Foundation
import SwiftUI


@Observable
class NatificationBar {
    private static var instance: NatificationBar = NatificationBar(isShowBar: false)
    
    var isShowBar:Bool
    
    var printContent: [String] = []
    
    private init(
        isShowBar: Bool
    ) {
        self.isShowBar = isShowBar
    }

    @ViewBuilder
    func content() -> some View {
        if isShowBar {
            LazyVStack {
                ForEach(printContent, id: \.endIndex) { content in
                    Text(content)
                }
                Spacer()
            }
            .background(Color("NormalBGColor").opacity(0.5))
            .clipShape(
                RoundedRectangle(cornerRadius: 5)
            )
        } else {
            EmptyView()
        }
    }

    func printContent(content: [String]) -> Void {
        printContent = content
        isShowBar = true
    }
    
    func close() {
        printContent.removeAll()
        isShowBar = false
    }
    
    
    static func getInstance() -> NatificationBar {
        return instance
    }
}
