import Foundation

struct Video: Identifiable, Hashable {
    let id: String
    let title: String
    let channel: String
    let views: String
    let age: String
    let duration: String
    let videoURL: URL
    let category: String

    var thumbnailURL: URL {
        URL(string: "https://picsum.photos/seed/\(id)/640/360")!
    }

    var channelAvatarURL: URL {
        URL(string: "https://picsum.photos/seed/\(channel.hashValue.magnitude % 1000)/96/96")!
    }
}

extension Video {
    static let samples: [Video] = [
        Video(
            id: "bunny",
            title: "Big Buck Bunny – 大きなウサギの冒険",
            channel: "Blender Foundation",
            views: "128万回視聴", age: "3年前", duration: "0:10",
            videoURL: URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_5MB.mp4")!,
            category: "アニメ"
        ),
        Video(
            id: "jellyfish",
            title: "海の中のクラゲをのんびり眺める",
            channel: "Ocean Moments",
            views: "42万回視聴", age: "1年前", duration: "0:10",
            videoURL: URL(string: "https://test-videos.co.uk/vids/jellyfish/mp4/h264/720/Jellyfish_720_10s_5MB.mp4")!,
            category: "自然"
        ),
        Video(
            id: "sintel",
            title: "Sintel – ドラゴンを探す少女",
            channel: "Blender Foundation",
            views: "310万回視聴", age: "5年前", duration: "0:10",
            videoURL: URL(string: "https://test-videos.co.uk/vids/sintel/mp4/h264/720/Sintel_720_10s_5MB.mp4")!,
            category: "アニメ"
        ),
        Video(
            id: "elephants",
            title: "Elephants Dream – 象の夢",
            channel: "Orange Open Movie",
            views: "56万回視聴", age: "8年前", duration: "10:53",
            videoURL: URL(string: "https://archive.org/download/ElephantsDream/ed_1024_512kb.mp4")!,
            category: "アニメ"
        ),
        Video(
            id: "sintel-full",
            title: "【フル】Sintel 長編アニメーション",
            channel: "Archive Cinema",
            views: "98万回視聴", age: "4年前", duration: "14:48",
            videoURL: URL(string: "https://archive.org/download/Sintel/sintel-2048-stereo_512kb.mp4")!,
            category: "映画"
        ),
        Video(
            id: "bbb-full",
            title: "【フル】Big Buck Bunny 720p サラウンド",
            channel: "Archive Cinema",
            views: "204万回視聴", age: "6年前", duration: "9:56",
            videoURL: URL(string: "https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4")!,
            category: "映画"
        ),
        Video(
            id: "bipbop",
            title: "Apple HLS テスト配信 – BipBop",
            channel: "Apple Developer",
            views: "17万回視聴", age: "2年前", duration: "0:30",
            videoURL: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!,
            category: "テック"
        ),
    ]

    static let categories = ["すべて", "アニメ", "映画", "自然", "テック"]
}
