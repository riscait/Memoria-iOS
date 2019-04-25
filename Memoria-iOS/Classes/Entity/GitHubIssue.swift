//
//  GitHubIssue.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/21.
//  Copyright © 2019 nerco studio. All rights reserved.
//

struct GitHubIssue: Codable {
    var htmlUrl: String // Snakecaseから変換するのでURLではなくUrlになる
    var title: String
    var createdAt: String
    var updatedAt: String
    var assignee: Assignee?
    
    struct Assignee: Codable {
        var avatarUrl: String
    }
}
