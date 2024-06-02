//
//  GithubUserListWireframe.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation
import SwiftUI

protocol GithubUserListWireframe {
    func toUserRepositoryList(entity: GithubSearchUserEntity) -> GithubUserRepositoryListView
}

class GithubUserListRouter: GithubUserListWireframe {
    func toUserRepositoryList(entity: GithubSearchUserEntity) -> GithubUserRepositoryListView {
        return GithubUserRepositoryListBuilder.build(entity: entity)
    }
}
