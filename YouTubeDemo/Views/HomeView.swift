≥import SwiftUI

struct HomeView: View {
    @State private var category = Video.categories[0]
    @State private var path: [Video] = []

    private var videos: [Video] {
        category == "すべて" ? Video.samples : Video.samples.filter { $0.category == category }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 0) {
                    chipBar
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16)], spacing: 20) {
                        ForEach(videos) { video in
                            Button { path.append(video) } label: {
                                VideoCard(video: video)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("YouTube")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Label("YouTube", systemImage: "play.rectangle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.red)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("通知", systemImage: "bell") {}
                    Button("検索", systemImage: "magnifyingglass") {}
                }
            }
            .navigationDestination(for: Video.self) { video in
                VideoPlayerScreen(video: video, related: Video.samples.filter { $0 != video })
            }
        }
    }

    private var chipBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Video.categories, id: \.self) { name in
                    Button(name) { category = name }
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            category == name ? Color.primary : Color.secondary.opacity(0.15),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                        .foregroundStyle(category == name ? Color(.systemBackground) : Color.primary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}
