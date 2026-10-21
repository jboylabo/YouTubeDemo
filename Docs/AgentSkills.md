# Apple Agent Skills 解説（iPhone Duo 対応）

このドキュメントは、`xcrun agent skills export` で書き出した Apple 公式スキルの仕組みと、本プロジェクトでの使い方をまとめたものです。
「技術基準」の節（末尾）は、そのまま社内の技術基準・開発ガイドラインに貼り付けて使えるように書いています。

参考: https://developer.apple.com/iphone-duo/prepare/

---

## 1. スキルとは

スキルは、AI コーディングエージェント（Claude Code など）に **Apple が公式に認めた最新の作法** を渡すための、Markdown ベースの指示書です。
モデルの学習済み知識は新しい OS の API に追いついていないことがあるため、スキルは「学習済み知識と食い違う場合はスキル側が正しい」と明示して上書きします（各 `SKILL.md` の冒頭に "supersedes prior training" と書かれています）。

スキルはコードではなく **テキスト** です。実行ファイルを組み込むわけではなく、アプリのビルド成果物には一切影響しません。

## 2. 書き出しの仕組み

```sh
xcrun agent skills export --output-dir <絶対パス> [--replace-existing]
```

- Xcode に同梱されたスキル定義を、ディスク上のディレクトリへ書き出すコマンドです（内部では `mcpbridge run-agent skills export`）。
- `--output-dir` には **絶対パス** を指定します。相対パスはルート `/` 基準で解釈され、`Read-only file system` エラーになります（実際に発生しました）。
- 既存のスキルを上書きするときは `--replace-existing` を付けます。
- 本プロジェクトでは `.claude/skills/` に出力しています。Claude Code はプロジェクト直下の `.claude/skills/` を自動で読むため、次回のセッションから有効になります。
- スキルは Xcode / SDK のバージョンに紐づいています。Xcode を更新したら再エクスポートして内容を更新してください。

## 3. ディレクトリ構成

```
.claude/skills/
└── <スキル名>/
    ├── SKILL.md          # 入口。メタデータ + 手順 + 参照ファイルの案内
    ├── references/*.md   # 詳細な規則・パターン集（必要なときだけ読む）
    └── scripts/          # 一部のスキルのみ。補助スクリプト
```

`SKILL.md` の先頭は YAML のメタデータです。

```yaml
---
name: app-resizability
description: "いつこのスキルを使うべきか（トリガー条件）"
---
```

## 4. 動作の仕組み（段階的読み込み）

1. **起動時**: エージェントは各スキルの `name` と `description` だけを読み込みます（軽量）。
2. **タスク時**: ユーザーの依頼が `description` のトリガー条件に合致すると、そのスキルの `SKILL.md` 本文が読み込まれます。
   例: 「iPhone Duo に対応したい」→ `app-resizability` が該当（description に iPhone Duo と明記されている）。
3. **必要時のみ**: `SKILL.md` が案内する `references/*.md` を、該当する API を扱うときだけ読みます。
4. 手順（検出 → 分析 → 置換 → 検証）や禁止事項は `SKILL.md` に書かれており、エージェントはそれに従って作業します。

この「description で選び、本文は必要なときだけ読む」構造により、コンテキストを節約しつつ最新の指針を適用できます。

## 5. 書き出された 11 スキル

| スキル | 用途 |
|---|---|
| `app-resizability` | iPhone Duo / 分割表示 / Stage Manager など、ウィンドウサイズが動的に変わるアプリへの対応。`UIScreen.main`、`interfaceOrientation`、`userInterfaceIdiom`、非対称なセーフエリア、アプリ単位のライフサイクルを、コンテキストに応じた API へ置換する |
| `swiftui-specialist` | SwiftUI のベストプラクティスと性能（アニメーション、`@Entry`、`@Observable`、`ForEach` の識別、ローカライズ、非推奨 API） |
| `swiftui-whats-new-27` | iOS 27 世代の SwiftUI の新規 API・挙動変更・非推奨（`@State` のマクロ化、`reorderable`、`AsyncImage` のキャッシュ、ツールバー、スワイプアクション等） |
| `app-intents-specialist` | App Intents の正しい実装作法 |
| `app-intents-whats-new-27` | iOS 26/27 で追加された App Intents の API |
| `device-interaction` | シミュレータ/実機でスクリーンショット・UI 階層・タップ操作を行い動作検証する（サブエージェント用） |
| `xctrace` | Instruments のコマンドライン版 `xctrace` によるプロファイリング |
| `modernize-tests` | XCTest から Swift Testing への移行 |
| `audit-xcode-security-settings` | セキュリティ関連のビルド設定の監査と有効化 |
| `building-document-based-swiftui-applications` | ドキュメントベース SwiftUI アプリ（`Document` プロトコル） |
| `adopt-c-bounds-safety` | C の `-fbounds-safety` の導入 |

## 6. `app-resizability` の中身（iPhone Duo 対応の中核）

iPhone Duo は折りたたみ機構により、**実行中に画面サイズが変わる** 端末です。そのため「画面サイズは起動時に決まる」という前提のコードが壊れます。
スキルは次の 5 つのタスクを順に適用します（`references/` に各 1 ファイル）。

| タスク | 置換の方針 |
|---|---|
| `UIScreen.main` | ビューの `traitCollection` や、所属するシーン/ウィンドウの値など、最も近い情報源を使う |
| 向き（orientation） | 向き判定ではなく、サイズクラスやウィンドウの bounds で判断する |
| シーンライフサイクル | `AppDelegate` 中心から `SceneDelegate` へ移行する |
| セーフエリア | `topLayoutGuide` 等をやめ、非対称で動的に変わるセーフエリアに対応する |
| `userInterfaceIdiom` | レイアウト目的の判定はサイズクラスへ。本当に必要な場合のみローカルの trait から読む |

共通原則（抜粋）:
- 最も近い情報源を使い、`UIApplication.shared` / `UIDevice.current` / `UIScreen.main` などのグローバル状態を代替に **使わない**。
- 動的な値をリテラルに置き換えない。
- 対象 API の行だけを変更し、周辺の整形や無関係な修正をしない。
- 呼び出し元を壊しうる変更はユーザーに確認する。

事前チェック（読み取り専用）:

| 項目 | 内容 |
|---|---|
| 起動画面 | 未宣言だと iOS 27 で App Store アップロードが `ITMS-90870` で拒否される（TN3208） |
| iPad の向き | 4 方向すべて宣言されていること |
| `UIRequiresFullScreen` | iOS 27 では無視され、ウィンドウは変更される（TN3192）。キーを削除したり、`UIRequiresFullScreenIgnoredStartingWithVersion` を勝手に追加したりしない |

## 7. 本プロジェクトでの適用状況

| 項目 | 状況 |
|---|---|
| 書き出し | 11 スキルを `.claude/skills/` に配置済み |
| 実際に参照したもの | `app-resizability`（`SKILL.md`）、`swiftui-whats-new-27`（`SKILL.md`）、`swiftui-specialist`（`SKILL.md` と、非推奨 API 一覧の `TabView` の記述）、`device-interaction`（`SKILL.md`） |
| 参照していないもの | 上記以外の `references/*.md` と、その他のスキル。`@Entry` や `@State` の詳細な規則は未確認 |
| 事前チェック結果 | 起動画面は `INFOPLIST_KEY_UILaunchScreen_Generation = YES` で宣言済み。iPad の向きは 4 方向宣言済み。`UIRequiresFullScreen` は未設定（いずれも問題なし）。iPhone の向きは縦と横 2 方向のみだが、スキルは iPhone を確認対象にしていない |
| `app-resizability` の置換タスク | **適用していない**。本アプリは SwiftUI のみで、`UIScreen.main`・`interfaceOrientation`・`userInterfaceIdiom`・`AppDelegate` を使っていないため、置換対象がなかった |
| 実装に反映した指針 | 旧 `TabView(selection:content:)` を避け、`Tab { }` 形式の `TabView` を使った。折りたたみへの対応は `UIScreen` や `UIDevice` を使わず、`GeometryReader` の幅と `DeviceHinge`（`onHingeChange`）で判断した |
| 動作検証 | `device-interaction` のツールは利用できなかった。代わりに `simctl` のスクリーンショットで、ホーム・動画再生・ショートの表示を確認した（タップ/スワイプ操作と、半開き時のレイアウトは未確認） |

## 8. 運用上の注意

- スキルは **指針であって保証ではない**。ビルドとシミュレータでの動作確認は別途必要。
- スキルは Xcode のバージョンに紐づく。Xcode 更新後は `--replace-existing` で再エクスポートする。
- `.claude/skills/` をコミットすると、チーム全員のエージェントが同じ指針で動く。不要ならコミットせず `.gitignore` に追加する。
- スキルの内容は英語。日本語の依頼でもトリガーは機能するが、判断に迷う場合は「iPhone Duo」「折りたたみ」など description に含まれる語を使うと確実。

---

## 技術基準（貼り付け用）

> ### iPhone Duo（折りたたみ iPhone）対応の技術基準
>
> **対象**: iOS 27 以降で、iPhone Duo・分割表示・Stage Manager のようにウィンドウサイズが実行中に変化する環境を想定するすべてのアプリ。
>
> **前提**
> - 画面サイズ・向き・端末種別を、起動時に一度だけ取得して固定値として扱わない。
> - レイアウトは「いま属しているビュー/ウィンドウ/シーン」の情報から決める。
>
> **禁止事項**
> 1. `UIScreen.main` / `UIScreen.mainScreen` を使わない。ビューの `traitCollection`、または所属するシーン/ウィンドウの値を使う。
> 2. レイアウトの判断に `interfaceOrientation` を使わない。サイズクラスまたはウィンドウの bounds を使う。
> 3. レイアウトの判断に `userInterfaceIdiom` を使わない。サイズクラスを使う。
> 4. セーフエリアを対称・固定とみなさない。`topLayoutGuide` / `bottomLayoutGuide` を使わず、セーフエリアの参照を使う。
> 5. `UIApplication.shared`・`UIDevice.current` などのグローバル状態を、上記の代替として使わない。
> 6. `UIRequiresFullScreen` を、レイアウトの対応が完了する前に削除しない。`UIRequiresFullScreenIgnoredStartingWithVersion` を安易に追加しない。
>
> **必須事項**
> - 起動画面を宣言する（`UILaunchScreen` 系キー）。未宣言の場合は iOS 27 で App Store 申請が拒否される（`ITMS-90870`、TN3208）。
> - iPad は 4 方向すべての向きを宣言する。
> - アプリのライフサイクルはシーンベースにする（SwiftUI は `App` / `WindowGroup`、UIKit は `SceneDelegate`）。
> - SwiftUI では、旧 `TabView(selection:content:)` や `NavigationView` などの soft-deprecated API を避け、`Tab` 形式の `TabView` と `NavigationStack` / `NavigationSplitView` を使う。
> - ヒンジ状態に応じて表示を変える場合は `onHingeChange` / `DeviceHinge` を使い、折りたたみ状態は表示に反映する。
>
> **確認手順**
> 1. Xcode 27 でビルドし、警告（特に非推奨 API）がないこと。
> 2. iPhone Duo シミュレータで、全画面・分割・半開きの各状態の画面を目視確認する。
> 3. ウィンドウをリサイズしても、レイアウトが崩れず、状態が失われないこと。
>
> **スキルの運用**
> - Apple 公式スキルを `xcrun agent skills export --output-dir <絶対パス>` で `.claude/skills/` に書き出し、AI エージェントの作業指針として使う。
> - Xcode の更新時は `--replace-existing` で再エクスポートする。
> - スキルの出力は指針であり、ビルドと実機/シミュレータでの確認を省略しない。
