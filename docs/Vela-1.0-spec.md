# Vela

iOS Home Screen / Lock Screen Layout Customization Tweak

## 1. 概要

Velaは、iOSのホーム画面およびロック画面上に存在する各UI要素のレイアウトを、画面上で直接確認しながら簡単に調整するためのJailbreak Tweak。

テーマ変更、色変更、フォント変更、Dock変更などは行わず、以下に限定する。

- 位置
- サイズ
- グリッド
- 間隔
- 余白
- レイアウト

Velaの基本思想は、

「設定画面で大量の数値を入力するのではなく、実際の画面を見ながら直接調整する」

こと。

Atriaのような簡単な操作感を目標とする。

---

# 2. 対応環境

## 対応端末

iPhoneのみ。

iPadは現時点では対象外。

## iOS

最低対応:

iOS 16

推奨:

iOS 17以降

iOS 16では一部機能が制限されてもよい。

可能な限りiOS 17以降を中心に実装すること。

## Jailbreak

Rootless環境を前提とする。

Rootful対応は不要。

## Orientation

Portraitのみ。

Landscapeへの対応は行わない。

---

# 3. 基本方針

Velaでは以下の機能を扱わない。

- Dockのカスタマイズ
- 色変更
- フォント変更
- 壁紙変更
- Blur変更
- アイコンテーマ
- 通知デザイン変更
- Quick Actionの機能変更
- 完全自由配置
- アイコンとWidgetの重なり
- Landscapeレイアウト

Velaはあくまで

「現在存在しているUI要素のレイアウトを変更する」

Tweakとする。

---

# 4. Respring

設定変更時にRespringを要求しないこと。

Vela Edit Modeで変更された内容はリアルタイムにSpringBoardへ反映する。

Doneを押した場合のみ設定を永続保存する。

Cancelを押した場合は編集開始時の状態へ戻す。

---

# 5. Vela Edit Mode

通常の設定画面だけでレイアウトを編集する形式にはしない。

実際のHome Screen / Lock Screen上で編集する。

---

# 6. Home Screen Edit Mode

## 起動方法

ホーム画面を長押しして、通常のSpringBoard編集モードへ入る。

編集モード中にVelaボタンを追加する。

例:

```text
Cancel                     Done

             Vela
```

Velaボタンを押すと、

Home Screen Vela Edit Mode

へ移行する。

---

# 7. Home Screenの対象

Home Screenでは以下を調整可能にする。

- 行数
- 列数
- アイコンサイズ
- Horizontal Spacing
- Vertical Spacing
- Grid X Position
- Grid Y Position
- Top Margin
- Bottom Margin
- Left Margin
- Right Margin
- Widget Layout
- Widget Scale
- Search / Spotlight Button Position
- Page Dots Position

Dockは対象外。

---

# 8. Home Screen Grid

ホーム画面は完全自由配置にはしない。

SpringBoardのグリッドシステムを維持したまま、グリッド自体を変更する。

例:

標準:

```text
□ □ □ □
□ □ □ □
□ □ □ □
□ □ □ □
□ □ □ □
□ □ □ □
```

5列:

```text
□ □ □ □ □
□ □ □ □ □
□ □ □ □ □
□ □ □ □ □
□ □ □ □ □
□ □ □ □ □
```

変更可能:

```text
Rows
Columns
Horizontal Spacing
Vertical Spacing
Icon Scale
Grid X
Grid Y
Margins
```

---

# 9. 全ページ共通

Home Screen Layoutは全ページ共通。

ページごとに異なるRows / Columns / Spacingを設定する機能は実装しない。

例:

Page 1 = 5 × 7  
Page 2 = 5 × 7  
Page 3 = 5 × 7

となる。

---

# 10. Widget

WidgetはHome Screen Grid内で扱う。

アイコンとの重なりは許可しない。

完全なAbsolute Positioningにはしない。

基本的にはAppleの既存Widget Layoutを維持しつつ、

- サイズ
- Scale
- グリッド内での配置

を調整可能にする。

Vela独自Scaleを許可する。

ただしScale変更によって他のアイコンやWidgetへ重なる場合は、可能な限り衝突しないようレイアウトを再計算する。

---

# 11. Home Screen Margin

以下を個別設定可能にする。

```text
Top
Bottom
Left
Right
```

MarginとSpacingは別設定として扱う。

Spacing:

アイコン同士の距離。

Margin:

画面端とグリッド領域の距離。

---

# 12. Search / Spotlight

Search ButtonまたはSpotlight関連UIは、

位置のみ変更可能。

サイズ変更は行わない。

対象:

```text
X
Y
```

---

# 13. Page Dots

Page Dotsも位置のみ変更可能。

```text
X
Y
```

サイズや色は変更しない。

---

# 14. Lock Screen Edit Mode

Lock ScreenにもVela Edit Modeを用意する。

編集対象:

- Clock
- Date
- Clock Block
- Widgets
- Left Quick Action
- Right Quick Action
- Notifications
- Now Playing

---

# 15. Lock Screen Clock

Clockでは以下を変更可能。

```text
X
Y
Scale
```

変更しないもの:

```text
Font
Font Weight
Color
Text Style
```

Clockをタップすると下部Editorを表示する。

例:

```text
Clock

Position
Scale

────────────

Reset
```

---

# 16. Clock Position

Clock選択中はドラッグ操作によって位置を変更できる。

自由移動を基本とする。

Snapが有効な場合は指定されたグリッドへ吸着する。

---

# 17. Clock Scale

Scaleはピンチ操作では変更しない。

誤操作防止のためBottom Sheet内のSliderを使用する。

例:

```text
Scale

────────●────
        92%
```

変更中はリアルタイムに反映する。

---

# 18. Date

DateもClockとは独立して移動可能。

対象:

```text
X
Y
```

必要であればScaleも内部的に対応可能な設計にしてよいが、無料版UIでは基本的に位置変更を中心とする。

---

# 19. Clock Block

ClockとDateをまとめて一つのグループとして移動できるモードを用意する。

```text
Clock Block

Clock
Date
```

Clock Block選択時はClockとDateの相対位置を維持したまま移動する。

Clock単体およびDate単体の調整も引き続き可能。

---

# 20. Lock Screen Widgets

時計下に存在するApple標準Widget Areaを対象とする。

Widgetを個別にAbsolute Positioningするのではなく、

Widget Area全体

を一つのLayout Elementとして扱う。

変更可能:

```text
X
Y
Scale
```

Vela独自Scaleを許可する。

Widget構成そのものの変更はApple標準Lock Screen Editorに任せる。

---

# 21. Quick Actions

左右のQuick Actionを別々のElementとして扱う。

```text
Left Quick Action
Right Quick Action
```

それぞれ独立して移動可能。

変更可能:

```text
X
Y
```

サイズ変更は無料版では行わない。

Quick Actionの機能変更も行わない。

例えばCameraを別アプリへ変更する機能はVelaの対象外。

---

# 22. Notifications

Lock Screen Notification Areaは以下すべて変更可能。

```text
X
Y
Width
Height
```

Notification Cellそのもののデザインは変更しない。

あくまでNotification Container / Notification Areaのレイアウトのみ変更する。

変更時は通知内容を再描画しながらリアルタイムで確認できることが望ましい。

---

# 23. Now Playing

Now Playingは位置のみ変更可能。

```text
X
Y
```

以下は変更しない。

```text
Scale
Color
Artwork Style
Blur
Layout Style
```

---

# 24. Element Selection

Vela Edit Modeでは対象Elementをタップして選択できるようにする。

選択中Elementは視覚的に判別できるようにする。

例:

- Border
- Highlight
- Selection Box
- Corner Handles

ただし通常のiOS UIから大きく逸脱しないデザインにする。

---

# 25. Bottom Editor

Elementを選択すると画面下部にEditorを表示する。

基本形式:

```text
Element Name

Position
Scale

────────────

Reset
```

Elementによって不要な項目は表示しない。

例:

Now Playing:

```text
Now Playing

Position

────────────

Reset
```

Clock:

```text
Clock

Position
Scale

────────────

Reset
```

---

# 26. Drag

Position変更可能なElementはドラッグで移動可能にする。

ドラッグ中は即座にSpringBoardへ反映する。

ドラッグ終了時の位置を現在値として保持する。

---

# 27. Snap

無料版でもSnap機能を提供する。

デフォルト:

```text
8px
```

Snap ON / OFFを切り替え可能。

Snap Sizeは以下から変更可能。

```text
1px
2px
4px
8px
16px
```

Custom数値入力は無料版では不要。

---

# 28. Alignment Guide

画面中央など特定のAlignment Pointへ近づいた場合、ガイドを表示する。

例:

```text
             │
             │
─────────────┼─────────────
             │
```

対象例:

- Horizontal Center
- Vertical Center
- Safe Area Center

ElementがガイドへSnapした際には軽いHaptic Feedbackを発生させる。

同じ位置でHapticを連続発生させないようにする。

一度ガイドから離れて再度Snapした場合のみ再発火する。

---

# 29. Position内部表現

各ElementのPositionは可能な限り以下形式で保持する。

```text
x
y
```

画面サイズ差に対応するため、必要に応じて以下いずれかを採用する。

- Offsetベース
- Anchor + Offset
- Normalized Coordinate

特定iPhoneモデルの絶対座標へ強く依存しない設計にする。

---

# 30. Editing Session

Vela Edit Mode開始時に現在設定のSnapshotを保存する。

例:

```text
editingSnapshot
```

編集中の変更はメモリ上のWorking Stateへ反映する。

```text
savedState
editingState
```

という形で分離すること。

---

# 31. Done

Doneを押した場合:

1. editingStateを永続保存
2. savedStateを更新
3. Vela Edit Mode終了
4. 現在レイアウトを維持

Respringしない。

---

# 32. Cancel

Cancelを押した場合:

1. editingSnapshotを復元
2. UIを編集開始前へ戻す
3. 永続保存しない
4. Edit Mode終了

Respringしない。

---

# 33. Undo

一般的な複数履歴Undo / Redoは実装しない。

ただしドラッグ開始前の状態を一時保持してよい。

例:

```text
dragStartPosition
```

現在のドラッグ操作をキャンセルする必要がある場合に利用する。

---

# 34. Reset Element

各ElementにResetを用意する。

例:

```text
Clock
→ Reset
```

ClockだけをApple標準レイアウト相当へ戻す。

他のElementには影響しない。

---

# 35. Reset Layout

Home Screen / Lock Screenそれぞれに全体Resetを用意する。

例:

```text
Reset Home Layout
Reset Lock Layout
```

全体Resetでは確認Alertを表示する。

例:

```text
Reset Home Screen Layout?

This will restore all Home Screen
layout settings to their defaults.

Cancel
Reset
```

---

# 36. Presets

無料版にPreset機能を含める。

HomeとLockは別管理。

```text
Home Layouts
Lock Layouts
```

---

# 37. Home Preset

Home Presetには以下を保存する。

```text
rows
columns

iconScale

horizontalSpacing
verticalSpacing

gridX
gridY

topMargin
bottomMargin
leftMargin
rightMargin

widgetSettings

searchPosition
pageDotsPosition
```

---

# 38. Lock Preset

Lock Presetには以下を保存する。

```text
clockPosition
clockScale

datePosition

widgetPosition
widgetScale

leftQuickActionPosition
rightQuickActionPosition

notificationFrame

nowPlayingPosition
```

---

# 39. Preset操作

以下を実装する。

```text
Create
Rename
Apply
Delete
```

Preset Apply時もRespring不要。

即座に現在のSpringBoardへ反映する。

---

# 40. Import / Export

Home Preset / Lock PresetはImport / Export可能にする。

内部形式はJSONを推奨する。

将来的には、

```text
.vela
```

Extensionを利用できる構造にする。

例:

```text
MinimalHome.vela
```

中身:

```json
{
  "version": 1,
  "type": "home",
  "name": "Minimal",
  "layout": {
    "rows": 7,
    "columns": 5,
    "iconScale": 0.9,
    "horizontalSpacing": 8,
    "verticalSpacing": 12,
    "gridX": 0,
    "gridY": -18
  }
}
```

---

# 41. Preset Version

Presetには必ずVersionを含める。

```json
"version": 1
```

将来設定項目が増えた場合にMigration可能な構造とする。

不明なKeyは可能な限り無視して読み込む。

---

# 42. Settings

Preference BundleまたはVelaの設定ページには最低限以下を用意する。

```text
Vela

Enabled

Home Screen
    Edit Layout
    Presets
    Reset Layout

Lock Screen
    Edit Layout
    Presets
    Reset Layout

Snap
    Enabled
    Grid Size

Compatibility

About
```

主要なレイアウト調整自体はSettings内ではなく、Vela Edit Modeで行う。

---

# 43. Compatibility Detection

Atriaなど、同じSpringBoard Layoutへ干渉するTweakを検出する。

競合Tweakが存在する場合は警告する。

例:

```text
Potential Conflict

Vela detected Atria.

Both tweaks modify Home Screen layout
and may cause unexpected behavior.

Continue Anyway
Disable Vela
```

競合TweakをVela側から勝手に削除・無効化しない。

ユーザーへ通知するだけにする。

---

# 44. Runtime Enable / Disable

Vela全体を設定から有効 / 無効化可能にする。

可能であればRespring不要で切り替える。

Disable時はApple標準レイアウトへ戻す。

再Enable時は保存済みVela Layoutを再適用する。

---

# 45. 保存

設定保存にはRootless環境で安全に利用できる方法を使用する。

設定内容は、

```text
HomeLayout
LockLayout
Presets
GeneralSettings
```

程度に分離する。

内部モデルと保存形式を密結合させないこと。

---

# 46. 推奨内部構造

実装は以下の責務へ分割する。

```text
VelaCore

VelaHome
VelaLock
VelaEditor
VelaPresets
VelaPreferences
VelaCompatibility
```

---

# 47. VelaCore

担当:

- 設定管理
- Layout State
- Runtime Apply
- Enable / Disable
- OS Version判定
- 共通API

---

# 48. VelaHome

担当:

- Home Screen Hook
- Grid Layout
- Icon Size
- Spacing
- Margin
- Widget Layout
- Search Position
- Page Dots Position

---

# 49. VelaLock

担当:

- Clock
- Date
- Widget Area
- Quick Actions
- Notifications
- Now Playing

---

# 50. VelaEditor

担当:

- Edit Mode
- Element Selection
- Drag
- Bottom Sheet
- Scale Slider
- Snap
- Alignment Guide
- Haptic
- Done
- Cancel
- Reset

Home / Lockで可能な限り共通化する。

---

# 51. VelaPresets

担当:

- Preset保存
- Apply
- Rename
- Delete
- Import
- Export
- Version Migration

---

# 52. VelaCompatibility

担当:

- 他Tweak検出
- Compatibility Warning
- OS差分管理

---

# 53. OSごとのPrivate API差

iOS 16 / 17 / 18以降でSpringBoard内部実装が異なる可能性がある。

Private Class名を一箇所へまとめる。

各HookへOS Version判定を大量に散らさない。

例:

```text
VelaCompatibility
    HomeAdapter
    LockAdapter
```

のようなAdapter方式を推奨する。

---

# 54. クラス取得失敗

Private ClassやViewが取得できなかった場合、

SpringBoardをクラッシュさせないこと。

必ずFail Safeする。

例:

```text
if targetView == nil:
    skip feature
```

特定機能だけ無効化し、Vela全体をクラッシュさせない。

---

# 55. Real-time Apply

Slider / Drag操作は高頻度で呼ばれるため、毎フレームPreferenceへ書き込まない。

編集中はメモリ上のStateを更新する。

永続保存は基本的にDone時。

View更新は可能な限り既存ViewへTransform / Frame / Constraint変更を適用する。

不要なView再生成は避ける。

---

# 56. Animation

Vela Edit Mode内の変更は基本的に短いAnimationまたはImmediate Updateとする。

ドラッグ中はAnimationなし。

Preset ApplyやResetなど一括変更では軽いAnimationを利用してよい。

---

# 57. Haptic

以下の場合のみ軽いHapticを使用。

- Center GuideへSnap
- Alignment GuideへSnap
- Optional: Preset Apply成功

ドラッグ中に大量のHapticを発生させない。

---

# 58. 無料版の範囲

この仕様書では無料版のみ実装する。

無料版でもVelaとして十分利用可能な状態にする。

有料版がなくても、

Home Screen / Lock Screen Layout Editor

として成立すること。

---

# 59. Advanced機能

将来的に別パッケージとしてAdvanced機能を提供する可能性がある。

ただし今回実装しない。

無料版のUIに大量のロック済み項目を表示する必要もない。

内部設計のみ、後から拡張可能にしておく。

将来想定:

```text
com.amania.vela.advanced
```

ただし無料版からAdvanced Packageへ依存してはいけない。

---

# 60. Advanced用に予約しておくもの

将来的に追加可能なよう設計だけ考慮する。

例:

- Exact X/Y Input
- Fractional Scale
- Custom Snap Value
- Detailed Margin
- Detailed Widget Size
- Fine Notification Layout
- Additional Preset Options

現時点では実装しない。

---

# 61. UX上の最重要事項

Velaを開いたユーザーが、

「X座標はいくつに設定すればいい？」

と考えなくても使えること。

基本操作は、

```text
Tap
Drag
Slider
Done
```

で完結させる。

細かい内部値は通常ユーザーへ意識させない。

---

# 62. Vela 1.0の優先順位

最優先:

1. Home Grid
2. Home Icon Scale / Spacing
3. Home Grid Position / Margin
4. Lock Clock Position
5. Lock Clock Scale
6. Lock Date Position
7. Lock Widget Position
8. Quick Action Position
9. Real-time Editing
10. Done / Cancel

次点:

11. Notifications
12. Now Playing
13. Search / Page Dots
14. Widget Scale
15. Snap
16. Alignment Guide
17. Presets

最後:

18. Import / Export
19. Compatibility Detection
20. iOS 16 Compatibility

---

# 63. 最初の実装

最初から全機能を同時に作らない。

Phase 1:

```text
Home Grid
Rows
Columns
Spacing
Grid Position
Done / Cancel
```

Phase 2:

```text
Icon Scale
Margin
Widgets
Search
Page Dots
```

Phase 3:

```text
Lock Clock
Date
Clock Block
Lock Widgets
Quick Actions
```

Phase 4:

```text
Notifications
Now Playing
Snap
Alignment Guide
Haptic
```

Phase 5:

```text
Presets
Import / Export
Compatibility
```

各Phase完了時点でSpringBoardが安定していることを確認してから次へ進む。

---

# 64. 安定性

SpringBoard Tweakなので、機能より安定性を優先する。

絶対条件:

- Safe Mode Loopを起こさない
- 存在しないViewへアクセスしない
- OS差分でクラッシュしない
- Edit Mode終了後にGesture Recognizerを残さない
- Observerを適切に解除する
- Viewを不必要にretainしない
- Vela Disable時に可能な限り元状態へ戻せる

---

# 65. 完成条件

Vela 1.0無料版は以下を満たした時点で完成とする。

Home Screen:

- Grid変更可能
- Rows / Columns変更可能
- Icon Scale変更可能
- Spacing変更可能
- Grid Position変更可能
- Margin変更可能
- Widget Layout変更可能
- Search位置変更可能
- Page Dots位置変更可能

Lock Screen:

- Clock移動可能
- Clock Scale変更可能
- Date移動可能
- Clock Block移動可能
- Widget Area移動可能
- Widget Scale変更可能
- Quick Actions個別移動可能
- Notifications X/Y/Width/Height変更可能
- Now Playing移動可能

Editor:

- 直接ドラッグ可能
- Slider Scale変更可能
- Snap可能
- Alignment Guide表示
- Haptic
- Reset Element
- Reset Layout
- Done / Cancel

System:

- Respring不要
- Preset保存可能
- Home / Lock Preset分離
- Import / Export可能
- Rootless対応
- iOS 17以降で安定動作
- iOS 16へ導入可能
- 他Layout Tweak検出時に警告
- Vela無効化時に標準レイアウトへ戻せる

以上をVela無料版1.0の仕様とする。