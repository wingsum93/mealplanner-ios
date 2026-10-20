import SwiftUI
import Kingfisher

/// A button label for browsing recipes by ingredient.
struct IngredientBrowseCapsule: View {
    let name: String
    var isSeeAll = false

    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .subheadline) private var imageSize = 40

    private var surface: Color {
        colorScheme == .dark
            ? Color(red: 0.18, green: 0.17, blue: 0.15)
            : Color(red: 0.97, green: 0.95, blue: 0.90)
    }

    private var accent: Color {
        colorScheme == .dark
            ? Color(red: 0.92, green: 0.68, blue: 0.43)
            : Color(red: 0.48, green: 0.29, blue: 0.14)
    }

    private var imageSurface: Color {
        colorScheme == .dark
            ? Color(red: 0.26, green: 0.24, blue: 0.20)
            : Color.white.opacity(0.8)
    }

    private var imageURL: URL? {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        return URL(string: "https://www.themealdb.com/images/ingredients/\(encoded)-small.png")
    }

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if isSeeAll {
                    Image(systemName: "square.grid.2x2")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(accent)
                } else {
                    KFImage(imageURL)
                        .placeholder {
                            Image(systemName: "leaf")
                                .foregroundStyle(accent.opacity(0.6))
                        }
                        .onFailureView {
                            Image(systemName: "leaf")
                                .foregroundStyle(accent)
                        }
                        .cancelOnDisappear(true)
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                }
            }
            .frame(width: imageSize, height: imageSize)
            .background(imageSurface, in: Circle())
            .clipShape(Circle())
            .accessibilityHidden(true)

            Group {
                if isSeeAll {
                    Text("See all")
                } else {
                    Text(name)
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(
                isSeeAll ? AnyShapeStyle(accent) : AnyShapeStyle(HierarchicalShapeStyle.primary)
            )
            .fixedSize(horizontal: true, vertical: false)

            if isSeeAll {
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accent)
                    .accessibilityHidden(true)
            }
        }
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .padding(.vertical, 8)
        .background(surface, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(accent.opacity(isSeeAll ? 0.28 : 0.10), lineWidth: 1)
        }
        .contentShape(Capsule())
        .accessibilityElement(children: .combine)
    }
}

#Preview("Warm ingredient capsules") {
    VStack(alignment: .leading, spacing: 24) {
        Text("Ingredients")
            .font(.system(.title2, design: .serif, weight: .semibold))
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                IngredientBrowseCapsule(name: "", isSeeAll: true)
                IngredientBrowseCapsule(name: "Chicken")
                IngredientBrowseCapsule(name: "Tomato")
                IngredientBrowseCapsule(name: "Extra Virgin Olive Oil")
            }
        }
    }
    .padding(16)
}

#Preview("Warm ingredient capsules · Dark") {
    VStack(alignment: .leading, spacing: 16) {
        IngredientBrowseCapsule(name: "", isSeeAll: true)
        IngredientBrowseCapsule(name: "Chicken")
        IngredientBrowseCapsule(name: "Extra Virgin Olive Oil")
    }
    .padding(16)
    .preferredColorScheme(.dark)
}
