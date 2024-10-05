//
//  KLineIntervalPicker.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/1.
//

import SwiftUI

struct KLineIntervalPicker: View {
    @Binding var kLineInterval:KLineInterval
    @State private var isPressed:Bool = false
    @State private var allIntervals:[KLineInterval] = KLineInterval.allCases
    

    var body: some View {
        Button {
            withAnimation {
                isPressed.toggle()
            }
        } label: {
            Text(kLineInterval.rawValue.toString())
                .frame(width: 35, height: 20)
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .background(Color("MetricIconBGColor"))
        }
        .padding(0)
        .buttonStyle(SelectButtonStyle())
        .frame(width: 35, height: 20)
        .clipShape(
            RoundedRectangle(cornerRadius: 2)
        )
        .sheet(isPresented: $isPressed) {
            Picker("K线间隔", selection: $kLineInterval) {
                ForEach(allIntervals, id: \.hashValue) { item in
                    Text(item.rawValue.toString()).tag(item)
                }
            }
            .font(.defaultFont())
        }
    }
}

#Preview {
    @Previewable @State var kLineInterval:KLineInterval = .d_1
    KLineIntervalPicker(kLineInterval: $kLineInterval)
}
