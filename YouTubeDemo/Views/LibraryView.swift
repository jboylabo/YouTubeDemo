import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("履歴") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Video.samples) { video in
                                AsyncImage(url: video.thumbnailURL) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle().fill(.quaternary)
                                }
                                .frame(width: 160, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
                Section {
                    Label("再生リスト", systemImage: "list.and.film")
                    Label("あなたの動画", systemImage: "play.square.stack")
                    Label("後で見る", systemImage: "clock")
                    Label("高く評価した動画", systemImage: "hand.thumbsup")
                }
            }
            .navigationTitle("ライブラリ")
        }
    }
}
