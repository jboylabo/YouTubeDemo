import AVKit
import SwiftUI

struct ShortsView: View {
    @State private var selection: String?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Video.samples) { video in
                    ShortPage(video: video, isActive: selection == video.id)
                        .containerRelativeFrame([.horizontal, .vertical])
                        .id(video.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $selection)
        .ignoresSafeArea()
        .background(.black)
        .onAppear { selection = Video.samples.first?.id }
    }
}

private struct ShortPage: View {
    let video: Video
    let isActive: Bool
    @State private var player: AVPlayer?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.black
            if let player {
                VideoPlayer(player: player).disabled(true)
            }
            LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .center, endPoint: .bottom)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 6) {
                Text("@\(video.channel)").font(.subheadline.bold())
                Text(video.title).font(.footnote).lineLimit(2)
            }
            .foregroundStyle(.white)
            .padding(.leading)
            .padding(.bottom, 100)

            VStack(spacing: 22) {
                railButton("hand.thumbsup.fill", "12万")
                railButton("hand.thumbsdown.fill", "低評価")
                railButton("text.bubble.fill", "1,203")
                railButton("arrowshape.turn.up.right.fill", "共有")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 84)
            .padding(.bottom, 100)
        }
        .onChange(of: isActive, initial: true) { _, active in
            if active {
                if player == nil {
                    let p = AVPlayer(url: video.videoURL)
                    p.isMuted = true
                    player = p
                }
                player?.play()
            } else {
                player?.pause()
            }
        }
    }

    private func railButton(_ systemImage: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage).font(.title2)
            Text(label).font(.caption2)
        }
        .foregroundStyle(.white)
    }
}
