# Vela — Phase 1

iPhone の Home Screen を直接編集する Rootless Tweak の初期実装です。iOS 16 を最低バージョンとし、iOS 17 の公開済み runtime header を基に Private API をアダプターへ集約しています。

**実機動作は未検証です。Phase 1 の安定性確認は未完了で、配布版ではありません。** クラウドの Linux では arm64 のコンパイルとパッケージ構造を検証します。iOS 14 以降の安定版 arm64e ABI は、この Linux ツールチェーンでは生成できません。arm64e を含む実機向けビルドには macOS / Xcode を使用してください。

## Phase 1 の内容

- Home Screen の通常編集モードに Vela ボタンを追加
- 全 Home ページ共通の Rows / Columns
- Apple のグリッドを維持した Horizontal / Vertical Spacing の追加調整（UIKit pt）
- Grid X / Y のスライダーとグリッド全体のドラッグ移動
- メモリ上のリアルタイムプレビュー、Done のみ永続保存、Cancel の復元
- 確認付き Reset（プレビューとして実行し、Done まで保存しない）

Dock・フォルダー・App Library は対象外です。Root Folder の全ページを事前検査し、アイコンが収まらないグリッドや Widget がある Home Screen は拒否します。Widget 対応、Icon Scale、Margin、Search、Page Dots は Phase 2、Lock Screen 編集は Phase 3 以降です。

位置はページサイズに対する比率として保存します。間隔は Apple の配置に追加する値です。画面端ではグリッド全体の間隔・移動量を制限し、個々のアイコンを端へ押し重ねません。未知のアイコン種別・取得できない Private API は適用対象から外します。ただし selector の存在は OS ごとの挙動の互換性を保証しません。

## クラウドでの開発

```sh
bash /workspace/tooling/setup-vela.sh
source /workspace/tooling/env-vela.sh
cd /workspace/Vela
make test
make -j2 package FINALPACKAGE=1
python3 Tests/verify_package.py packages/com.amania.vela_0.1.0_iphoneos-arm64.deb
```

既存 checkout を使います。クラウドタスクは隔離済みのため、新しい Git worktree は作成しません。サーバー・秘密鍵・API キーは不要です。生成物は `.theos/`、`build/`、`packages/` に出力され、Git 対象外です。

`make test` は Linux 上で C の編集セッション・値検証・容量判定・座標計算を ASan / UBSan 付きで検証します。Objective-C の保存処理、UIKit UI、Private API の実行はこのテストの対象外です。パッケージ検査は Rootless パス、所有権、SpringBoard のフィルター、Mach-O のアーキテクチャ、最低 OS と署名コマンドの存在を確認します。

## macOS での実機向けビルド

Xcode と Theos、iOS SDK を導入し、使用する SDK のバージョンを `TARGET` で指定します。例:

```sh
make THEOS="$THEOS" TARGET=iphone:clang:latest:16.0 -j2 package FINALPACKAGE=1
```

macOS の既定は `arm64 arm64e` です。Linux で `ARCHS=arm64e` を指定して生成したバイナリは使用しないでください。初回インストールでは SpringBoard への Tweak 読み込みが必要ですが、レイアウトの編集・保存・Cancel のコードには Respring 処理を入れていません。

## 実機検証（すべて未実行）

1. iOS 17 以降の Rootless iPhone で、通常編集モード → Vela の入口・編集対象が表示されることを確認。
2. 複数ページで行・列・間隔・ドラッグ位置が即時反映され、アイコンの順序・数・Dock が保たれることを確認。
3. Cancel と Reset → Cancel で編集開始時のグリッド・位置へ戻り、設定ファイルが更新されないことを確認。
4. Done と SpringBoard 再起動で保存値が戻ること、保存失敗時は編集を継続できることを確認。
5. 満杯のページ・Widget のあるページ・未知の API で拒否され、アイコンが失われないことを確認。
6. 編集中の画面ロック・通常編集モード終了・回転で Cancel され、Editor やジェスチャーが残らないことを確認。
7. 小さい画面・大きい画面で重なり・画面外への配置・タップ領域のずれを確認。
8. iOS 16 と利用する iOS 18 以降でも Private API を確認し、機能単位の未対応を記録。

これらが完了するまで Phase 2 へは進めません。Safe Mode やインジェクションの互換性は実機で検証してください。

## 構造と保存

`VelaCore` はプラットフォーム非依存のモデルと編集セッション、JSON 保存を担当します。`VelaCompatibility` が Private API と Home 全ページの容量判定、`VelaHome` が Hook、`VelaEditor` が編集 UI を担当します。

保存先は SpringBoard を実行するユーザーの `Library/Preferences/com.amania.vela.home.json`。version 1 の JSON を原子的に書き込み、未知のキーを無視し、不正値や未知バージョンは標準状態へ戻します。スライダーやドラッグではファイルを書き込みません。

元リポジトリにはコミット・`main` がなかったため、Phase 1 を初期実装として追加しています。
