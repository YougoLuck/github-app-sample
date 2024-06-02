//
//  GithubSearchUserEntity.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation

struct GithubSearchUserEntity: Codable, Hashable {
    // ユーザー名
    var login: String
    // アイコン画像URL
    var avatarUrl: String
}

struct GithubSearchUserApiResponse: Codable {
    var totalCount: Int
    var incompleteResults: Bool
    var items: [GithubSearchUserEntity]
}
