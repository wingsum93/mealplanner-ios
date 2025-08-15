//
//  RoundedButton.swift
//  Meal Planner
//
//  Created by eric ho on 15/8/2025.
//

import SwiftUI

struct YoutubeRoundedButton: View {
    var title: String
    var systemImage: String
    var url:URL
    var backgroundColor:Color = .orange
    
    
    @Environment(\.openURL) private var openURL
    
    init(title: String, systemImage: String, link:String) {
        self.title = title
        self.systemImage = systemImage
        self.url = URL(string:link ) ?? URL(string:"https://www.youtube.com/")!
    }

    var body: some View {
        Button(action: {
            openURL(url)
            print("yt click")
        }) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title.uppercased()) // 全大寫
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white) // icon + text 顏色
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .buttonStyle(.plain) // 移除系統按鈕樣式
        .frame(width: .infinity)
    }
}

