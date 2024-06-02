//
//  GithubUserRepositoryListPresenter.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation

class GithubUserRepositoryListPresenter: ObservableObject {
    let router: GithubUserRepositoryListWireframe
    private let githubUserDetailUseCase: GithubUserDetailUseCase
    private let githubUserRepositoryUseCase: GithubUserRepositoryUseCase
    
    private var page = 1
    @Published private(set) var canLoadMore = false
    @Published private(set) var isLoading = false
    @Published private(set) var userDetailEntity: GithubUserDetailEntity
    @Published private(set) var repositoryEntities: [GithubRepositoryEntity] = []
    

    private var initFlag = false
    private let userID: String
    
    init(
        entity: GithubSearchUserEntity,
        router: GithubUserRepositoryListWireframe,
        githubUserDetailUseCase: GithubUserDetailUseCase,
        githubUserRepositoryUseCase: GithubUserRepositoryUseCase
    ) {
        userID = entity.login
        userDetailEntity = GithubUserDetailEntity(
            login: entity.login,
            avatarUrl: entity.avatarUrl,
            name: nil,
            followers: .zero,
            following: .zero
        )
        self.router = router
        self.githubUserDetailUseCase = githubUserDetailUseCase
        self.githubUserRepositoryUseCase = githubUserRepositoryUseCase
    }
    
    func appear() {
        guard !initFlag else { return }
        initFlag.toggle()
        Task {
            await refresh()
        }
    }
    
    func refresh() async {
        await MainActor.run {
            resetRequestState()
            isLoading = true
        }
        let userDetailRes = await githubUserDetailUseCase.get(userID: userID)
        let repositoryRes = await githubUserRepositoryUseCase.get(
            userID: userID,
            request: GithubUserRepositoryRequest(page: page)
        )
        await MainActor.run {
            isLoading = false
            switch userDetailRes {
            case .success(let data):
                userDetailEntity = data
            case .failure:
                break
            }
            
            switch repositoryRes {
            case .success(let data):
                repositoryEntities = data.filter { !$0.fork }
                canLoadMore = calculateCanLoadMore(response: data)
            case .failure:
                break
            }
        }
    }
    
    func loadMore() {
        page += 1
        isLoading = true
        Task {
            let repositoryRes = await githubUserRepositoryUseCase.get(
                userID: userID,
                request: GithubUserRepositoryRequest(page: page)
            )
            await MainActor.run {
                isLoading = false
                switch repositoryRes {
                case .success(let data):
                    repositoryEntities.append(contentsOf: data.filter { !$0.fork })
                    canLoadMore = calculateCanLoadMore(response: data)
                case .failure:
                    break
                }
            }
        }
    }
    
    private func resetRequestState() {
        page = 1
        canLoadMore = false
        repositoryEntities = []
    }
    
    private func calculateCanLoadMore(
        response: [GithubRepositoryEntity]
    ) -> Bool {
        return response.count > .zero
    }
}
