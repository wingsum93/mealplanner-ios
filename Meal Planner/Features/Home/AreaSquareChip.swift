//
//  AreaSquareChip.swift
//  Meal Planner
//
//  Created by eric ho on 14/8/2025.
//
import SwiftUI

struct AreaSquareChip: View {
    var title: String
    var size: CGFloat = 88

    private var imageURL: URL? {
        URL(string: title.areaImageURL())
    }

    var body: some View {
        ZStack {
            // Background image
            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().fill(Color(.systemGray5))
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(Image(systemName: "photo").foregroundColor(.secondary))
                    @unknown default:
                        Rectangle().fill(Color(.systemGray5))
                    }
                }
            } else {
                // Fallback gradient + icon
                LinearGradient(
                    colors: [Color.blue.opacity(0.25), Color.green.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    Image(systemName: "globe.asia.australia.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.6))
                )
            }

            // Dark overlay for text
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.3))

            // Centered title
            Text(title)
                .font(.footnote.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 6)
                .lineLimit(2)
                .shadow(radius: 3)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
private extension String {
    func areaImageURL() -> String {
        let map: [String: String] = [
            "American": "https://flagcdn.com/w320/us.png",
            "British":  "https://flagcdn.com/w320/gb.png",
            "Canadian": "https://flagcdn.com/w320/ca.png",
            "Chinese":  "https://flagcdn.com/w320/cn.png",
            "Croatian": "https://flagcdn.com/w320/hr.png",
            "Dutch": "https://flagcdn.com/w320/nl.png",
            "Egyptian": "https://flagcdn.com/w320/eg.png",
            "Filipino": "https://flagcdn.com/w320/ph.png",
            "French":   "https://flagcdn.com/w320/fr.png",
            "Greek":    "https://flagcdn.com/w320/gr.png",
            "Indian":   "https://flagcdn.com/w320/in.png",
            "Irish":    "https://flagcdn.com/w320/ie.png",
            "Italian":  "https://flagcdn.com/w320/it.png",
            "Jamaican": "https://flagcdn.com/w320/jm.png",
            "Japanese": "https://flagcdn.com/w320/jp.png",
            "Kenyan":   "https://flagcdn.com/w320/ke.png",
            "Malaysian": "https://flagcdn.com/w320/my.png",
            "Mexican":  "https://flagcdn.com/w320/mx.png",
            "Moroccan": "https://flagcdn.com/w320/ma.png",
            "Polish":   "https://flagcdn.com/w320/pl.png",
            "Portuguese": "https://flagcdn.com/w320/pt.png",
            "Russian":  "https://flagcdn.com/w320/ru.png",
            "Spanish":  "https://flagcdn.com/w320/es.png",
            "Thai":     "https://flagcdn.com/w320/th.png",
            "Turkish":  "https://flagcdn.com/w320/tr.png",
            "Ukrainian": "https://flagcdn.com/w320/ua.png",
            "Vietnamese": "https://flagcdn.com/w320/vn.png",
        ]
        return map[self] ?? ""
    }
}

