//
//  GithubUserRepositoryListBuilder.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation

final class GithubUserRepositoryListBuilder {
    static func build(entity: GithubSearchUserEntity) -> GithubUserRepositoryListView {
        let githubUserDetailUseCase = GithubUserDetailInteractor(httpClient: HttpClient.client)
        let githubUserRepositoryUseCase = GithubUserRepositoryInteractor(httpClient: HttpClient.client)
        
        let presenter = GithubUserRepositoryListPresenter(
            entity: entity,
            router: GithubUserRepositoryListRouter(),
            githubUserDetailUseCase: githubUserDetailUseCase,
            githubUserRepositoryUseCase: githubUserRepositoryUseCase
        )
        
        return GithubUserRepositoryListView(presenter: presenter)
    }
}
