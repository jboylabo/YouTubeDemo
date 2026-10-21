import SwiftUI

struct SubscriptionsView: View {
    private let channels = Array(Set(Video.samples.map(\.channel))).sorted()
    @State private var path: [Video] = []

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(channels, id: \.self) { channel in
                                VStack {
                                    Circle().fill(.red.gradient)
                                        .frame(width: 60, height: 60)
                                        .overlay {
                                            Text(channel.prefix(1)).font(.title2.bold()).foregroundStyle(.white)
                                        }
                                    Text(channel).font(.caption2).lineLimit(1).frame(width: 72)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16)], spacing: 20) {
                        ForEach(Video.samples.reversed()) { video in
                            Button { path.append(video) } label: { VideoCard(video: video) }
                                .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("登録チャンネル")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Video.self) { video in
                VideoPlayerScreen(video: video, related: Video.samples.filter { $0 != video })
            }
        }
    }
}
