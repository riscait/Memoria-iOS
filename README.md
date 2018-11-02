# 導入 
Memoria-iOSは、Memoria（メモリア）プロジェクトのiOSアプリリポジトリです。

# 開発の始め方
Memoria-iOSの開発の始め方を解説します。
## インストール手順
1.	当リポジトリをクローンします。  ↓以下、コマンドの場合
    ```
    git clone https://{ユーザーID}@dev.azure.com/nerco/Memoria/_git/Memoria-iOS
    ```
2.	CocoaPodsを使って、必要なライブラリをインストールします。
    ```
    pod install
    ```
3.	Xcodeを立ち上げてまずは「ビルド」しましょう！

# 使用ライブラリ
## CocoaPodsで管理
1.  Firebase Core
2.  Firestore（データベース機能）

## Carthageで管理
まだなし