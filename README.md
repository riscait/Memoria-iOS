# これは何？
Memoria-iOSは、Memoria（メモリア）プロジェクトのiOSアプリリポジトリです。

# 開発の始め方
Memoria-iOSの開発の始め方を解説します。
主に「ターミナル」を使ったコマンドを紹介しますが、その他GUIソフトを使う方はそちらを使ってください。

## 意識すべきバージョン情報と調べ方
1. Xcode 10.1  
   [Xcodeのバージョン確認方法](http://pippi-pro.com/xcode-version-confirmation)

2. Swift 4.2.1
   ```
   Swift --version
   ```

## Memoria for iOS をクローンしてライブラリをインストールする
1.	クローンします。（お好きな方法で♪下記は一例）
    ```
    git clone git@github.com:Riscait/Memoria-iOS.git
    ```
2.	Podsファイルはリポジトリに含まれているので pod installは不要です。

3.	Xcodeを立ち上げてまずは「ビルド」しましょう！

# 使用ライブラリ
## CocoaPodsで管理
1.  Firebase Core
2.  Firestore（データベース機能）

## Carthageで管理
1.  まだなし
