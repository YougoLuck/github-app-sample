//
//  GithubUserDetailEntity.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation

struct GithubUserDetailEntity: Codable {
    // ユーザー名
    var login: String
    // アイコン画像URL
    var avatarUrl: String
    // フルネーム
    var name: String?
    // フォローワー数
    var followers: Int
    // フォロー数
    var following: Int
}
