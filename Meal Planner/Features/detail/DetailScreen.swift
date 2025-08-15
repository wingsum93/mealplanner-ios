//
//  DetailScreen.swift
//  Meal Planner
//
//  Created by eric ho on 13/8/2025.
//
import SwiftUI
import Kingfisher

struct DetailScreen: View {
    @ObservedObject var vm: FeatureViewModel
    let id: String

    var body: some View {
        content
            // If user navigates straight here, ensure load fires
            .task {
                if vm.state.detail.item?.id != id && vm.state.detail.phase != .loading {
                    vm.onIntent(.loadDetail(id))
                }
            }
    }

    // Pull the control flow out of the body so inference is simpler
    @ViewBuilder
    private var content: some View {
        switch vm.state.detail.phase {
        case .loading:
            SkeletonDetailView()
                .navigationTitle("Loading…")

        case .empty:
            EmptyStateView(message: "Recipe not found", systemImage: "fork.knife")
                .navigationTitle("Details")

        case .error(let msg):
            ErrorView(message: msg, actionTitle: "Retry") {
                vm.onIntent(.loadDetail(id))
            }
            .navigationTitle("Details")

        case .content, .idle:
            if let item = vm.state.detail.item {
                DetailContent(item: item) {
                    // ✅ add the missing label for the second argument
                    vm.onIntent(.toggleFavorite(id: item.id, isFavorite: !item.isFavorite))
                }
                .navigationTitle(item.name)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            // ✅ same fix here
                            vm.onIntent(.toggleFavorite(id: item.id, isFavorite: !item.isFavorite))
                        } label: {
                            Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                .foregroundStyle(item.isFavorite ? .red : .primary)
                        }
                    }
                }
            } else {
                EmptyStateView(message: "No details yet", systemImage: "fork.knife")
                    .navigationTitle("Details")
            }
        }
    }
}

// MARK: - Detail content (hero image + meta + actions)
private struct DetailContent: View {
    let item: UIRecipeItem
    var onToggleFavorite: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Hero header
                ZStack(alignment: .bottomLeading) {
                    KFImage(item.thumbURL)
                        .placeholder {
                            Color.gray // 載入中顯示
                        }
                        .resizable()
                        .scaledToFill()
                        .overlay(// gradient locked to same bounds
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.55)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .allowsHitTesting(false)
                            , alignment: .bottom
                        )
                        .clipped()

                    // Title + meta chips (also clipped by parent)
                    // Title + meta chips (also clipped by parent)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.name)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .shadow(radius: 4)
                        
                        HStack(spacing: 8) {
                            if let area = item.area, !area.isEmpty {
                                MetaChip(text: area, systemImage: "globe.asia.australia.fill")
                            }
                            if let cat = item.category, !cat.isEmpty {
                                MetaChip(text: cat, systemImage: "square.grid.2x2")
                            }
                        }
                        HStack(spacing: 8) {
                            ForEach(item.tags,id: \.self){ tag in
                                TextChip(text: tag)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity)                // take full screen width
                .aspectRatio(1, contentMode: .fit)         // square header sized by width
                .contentShape(Rectangle())                 // clearer hit test bounds
                .clipped()
                // Actions row
                HStack(spacing: 12) {
                    Button(action: onToggleFavorite) {
                        Label(item.isFavorite ? "Favourited" : "Add to Favourites",
                              systemImage: item.isFavorite ? "heart.fill" : "heart")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(Color.accentColor.opacity(0.1))
                            )
                    }

                    // Placeholder share; wire up later if you have source URL
                    ShareLink(item: item.name) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(Color(.systemGray6))
                            )
                    }
                }
                .padding(.horizontal, 16)

                //Description
                Text("Description")
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading, 8)
                Text(item.description)
                    .font(.caption)
                    .fontWeight(.regular)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading, 8)
                
                //Instruction
                Label("Instructions", systemImage: "arrow.triangle.2.circlepath")
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading, 8)
                VStack(alignment: .leading){
                    ForEach(item.instructions.indices,id:\.self){ num in
                        let text = "\(num+1). " + item.instructions[num]
                        Text(text)
                            .font(.footnote)
                        if num != item.instructions.count-1 {
                            Spacer(minLength: 10)
                        }
                    }
                }
                
                
                // Ingredients
                Label("Ingredients", systemImage: "arrow.triangle.2.circlepath")
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading, 8)
                ForEach(item.ingredients,id:\.self){ ins in
                    Text(ins)
                        .font(.footnote)
                }
                
                // Watch Button
                YoutubeRoundedButton(
                    title: "Watch Video", systemImage: "arrowtriangle.right.fill", link: item.youtubeLink
                )
            }
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Small pill for meta tags
private struct MetaChip: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: systemImage)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Color.white.opacity(0.85))
        )
        .foregroundStyle(.black.opacity(0.8))
    }
}

// MARK: - Skeleton while loading
private struct SkeletonDetailView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(.systemGray5))
                    .frame(height: 280)
                    .shimmer()

                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray5))
                        .frame(width: 140, height: 32)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray5))
                        .frame(width: 100, height: 32)
                    Spacer()
                }
                .padding(.horizontal, 16)

                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 120)
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
    }
}

// Optional shimmer helper
private extension View {
    func shimmer(active: Bool = true) -> some View {
        self
            .redacted(reason: active ? .placeholder : [])
            .overlay(
                LinearGradient(stops: [
                    .init(color: .clear, location: 0.3),
                    .init(color: .white.opacity(0.35), location: 0.5),
                    .init(color: .clear, location: 0.7),
                ], startPoint: .leading, endPoint: .trailing)
                .rotationEffect(.degrees(10))
                .offset(x: -200)
                .mask(self)
                .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: UUID())
            )
    }
}

#Preview("have data"){
    DetailContent(item: .sample) {
        print("abc .")
    }
}
