![platforms](https://img.shields.io/badge/platforms-iOS-333333.svg)
[![Language: Swift 5.0](https://img.shields.io/badge/swift-5.0-4BC51D.svg?style=flat)](https://developer.apple.com/swift)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/Riscait/Memoria-iOS/master/LICENSE)

# What's this?
Memoria-iOSは、Memoria（メモリア）プロジェクトのiOSアプリリポジトリです。

# Development requirement
## Development environment
1. Xcode 10.2.1
2. Swift 5.0

## How to start development
Memoria-iOSの開発の始め方を解説します。
主に「ターミナル」を使ったコマンドを紹介しますが、その他GUIソフトを使う方はそちらを使ってください。

## Using "Library"
### CocoaPodsで管理
1. Firebase Core
2. FirebaseAuth（認証機能）
3. Firestore（データベース機能）
4. Repro

### Carthageで管理
1. DZNEmptyDataSet

## Architecture(設計パターン)
MVP(Passive View)に移行中

## Using "GitHub Flow"
1. masterブランチはいつでもデプロイ可能状態
2. 機能追加と不具合修正はmasterブランチから切って(e.g. add-brack-thema)プルリクエスト

---
Copyright 2019 村松 龍之介 (Muramatsu Ryunosuke)
