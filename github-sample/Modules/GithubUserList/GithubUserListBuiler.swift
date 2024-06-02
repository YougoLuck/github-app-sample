//
//  GithubUserListBuiler.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation

final class GithubUserListBuiler {
    static func build() -> GithubSearchUserView {
        let githubSearchUsersUseCase = GithubSearchUsersInteractor(httpClient: HttpClient.client)
        
        let presenter = GithubUserListPresenter(
            router: GithubUserListRouter(),
            githubSearchUsersUseCase: githubSearchUsersUseCase
        )
        
        return GithubSearchUserView(presenter: presenter)
    }
}
