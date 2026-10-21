import AVKit
import SwiftUI

struct VideoPlayerScreen: View {
    let video: Video
    let related: [Video]

    @Environment(\.hinge) private var hinge
    @State private var player: AVPlayer
    @State private var current: Video

    init(video: Video, related: [Video]) {
        self.video = video
        self.related = related
        _current = State(initialValue: video)
        _player = State(initialValue: AVPlayer(url: video.videoURL))
    }

    var body: some View {
        GeometryReader { proxy in
            if hinge?.status == .partiallyOpen {
                // テーブルトップ: 上半分にプレイヤー、下半分に詳細・関連動画
                VStack(spacing: 0) {
                    playerView.frame(height: proxy.size.height / 2)
                    details
                }
            } else if proxy.size.width > 700 {
                HStack(alignment: .top, spacing: 0) {
                    ScrollView { VStack(alignment: .leading) { playerView; info } }
                    Divider()
                    relatedList.frame(width: min(proxy.size.width * 0.35, 420))
                }
            } else {
                VStack(spacing: 0) {
                    playerView
                    details
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { player.play() }
        .onDisappear { player.pause() }
    }

    private var playerView: some View {
        VideoPlayer(player: player)
            .aspectRatio(16 / 9, contentMode: .fit)
            .background(.black)
    }

    private var details: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                info
                ForEach(related) { item in
                    Button { play(item) } label: { VideoCard(video: item) }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
    }

    private var relatedList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(related) { item in
                    Button { play(item) } label: { VideoCard(video: item) }
                        .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(current.title).font(.headline)
            Text("\(current.views) ・ \(current.age)")
                .font(.caption).foregroundStyle(.secondary)

            HStack {
                Label(current.channel, systemImage: "person.crop.circle.fill")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button("チャンネル登録") {}
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)
                    .foregroundStyle(Color(.systemBackground))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    actionButton("高く評価", "hand.thumbsup")
                    actionButton("低く評価", "hand.thumbsdown")
                    actionButton("共有", "arrowshape.turn.up.right")
                    actionButton("保存", "bookmark")
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private func actionButton(_ title: String, _ systemImage: String) -> some View {
        Button {} label: { Label(title, systemImage: systemImage) }
            .buttonStyle(.bordered)
            .tint(.secondary)
            .foregroundStyle(.primary)
    }

    private func play(_ item: Video) {
        current = item
        player.replaceCurrentItem(with: AVPlayerItem(url: item.videoURL))
        player.play()
    }
}
