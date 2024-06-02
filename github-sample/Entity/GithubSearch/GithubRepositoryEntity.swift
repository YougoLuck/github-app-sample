//
//  GithubRepositoryEntity.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation

struct GithubRepositoryEntity: Codable, Hashable {
    let name: String
    let description: String?
    let fork: Bool
    let language: String?
    let stargazersCount: Int?
}
