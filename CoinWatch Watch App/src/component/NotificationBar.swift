//
//  NotificationBar.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/28.
//

import Foundation
import SwiftUI

//protocol ContainerView: View {
//    associatedtype Content
//    init(content: @escaping () -> Content)
//}
//
//extension ContainerView {
//    init(@ViewBuilder _ content: @escaping () -> Content) {
//        self.init(content: content)
//    }
//}
class NatificationBar :ObservableObject {
    @Published var isShowBar:Bool
    
    @Published var dynamicContent: AnyView
    
    init(
        isShowBar: Bool,
        dynamicContent: AnyView
    ) {
        self.dynamicContent = dynamicContent
        self.isShowBar = isShowBar
    }

    @ViewBuilder
    func content() -> some View {
        if isShowBar {
            dynamicContent
        } else {
            EmptyView()
        }
        
    }

    func printContent(anyView: AnyView) -> Void {
        print("123")
        dynamicContent = anyView
        isShowBar = true
    }
    
    func closeBar() -> Void {
        isShowBar = false
    }
}


#Preview{

}
