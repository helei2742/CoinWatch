//
//  DollarIcon.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/21.
//

import SwiftUI

struct DollarIcon: View {
    var body: some View {
        Image(systemName: "dollarsign")
            .resizable()
            .font(.largeTitle)
            .scaledToFit()
    }
}

#Preview {
    DollarIcon()
}
