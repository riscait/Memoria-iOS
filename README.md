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
3. CocoaPods 1.5.3
   ```
   pod --version
   ```

## Memoria for iOS をクローンしてライブラリをインストールする
1.	クローンします（DevOpsのRepos→CloneボタンからもURLをた確認することができます）
    ```
    git clone https://{ユーザーID}@dev.azure.com/nerco/Memoria/_git/Memoria-iOS
    ```
2.	CocoaPodsを使って、必要なライブラリをインストールします。
    ※podfileはGitに含まれています。
    ```
    pod install
    ```
3.	Xcodeを立ち上げてまずは「ビルド」しましょう！

# 使用ライブラリ
## CocoaPodsで管理
1.  Firebase Core
2.  Firestore（データベース機能）

## Carthageで管理
1.  まだなし
