import SwiftUI

struct VideoCard: View {
    let video: Video

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: video.thumbnailURL) { image in
                    image.resizable().aspectRatio(16 / 9, contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(.quaternary)
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .overlay { ProgressView() }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(video.duration)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 4))
                    .padding(8)
            }

            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: video.channelAvatarURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(.quaternary)
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(video.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                    Text("\(video.channel) ・ \(video.views) ・ \(video.age)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}
