//
//  GitHubAPIClient.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/21.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation

struct GitHubAPIClient {
    
    enum IssueType: String {
        case bug = "バグ"
        case enhancement = "機能強化"
    }
    
    private static let repository = "https://api.github.com/repos/Riscait/Memoria-iOS/"
    
    /// 指定したラベルのIssueを[GitHub REST API]を使用して取得する
    static func getIssues(type issueType: IssueType, callback: @escaping ([GitHubIssue]) -> Void) {
        
        guard let encodedIssueType = issueType.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "\(repository)issues?labels=\(encodedIssueType)&sort=updated") else { return }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                Log.warn("エラー発生: \(error)")
                return
            }
            guard let data = data else {
                Log.warn("データが見つかりません")
                return
            }
            do {
                let decoder = JSONDecoder()
                // 用意した構造体に合わせて、JSONのキーのスネークケースをキャメルケースに変換する
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                // データの形式をJSONからGitHubIssueに変換する
                let issues = try decoder.decode([GitHubIssue].self, from: data)
                Log.info("\(issueType)のIssueを取得: \(issues)")
                callback(issues)
                
            } catch let error {
                Log.warn("エラー発生: \(error)")
            }
        }
        dataTask.resume()
    }
}
