//
//  GithubUserListPresenter.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation


final class GithubUserListPresenter: ObservableObject {
    private let githubSearchUsersUseCase: GithubSearchUsersUseCase
    let router: GithubUserListWireframe
    
    @Published var searchInput: String = ""
    private var searchingInput: String = ""
    
    
    var userEntitiesCnt: Int {
        return userEntities.count
    }
    
    var shouldShowList: Bool {
        return userEntities.count > .zero
    }
    
    private var page = 1
    @Published private(set) var isLoading = false
    @Published private(set) var canLoadMore = false
    @Published private(set) var userEntities: [GithubSearchUserEntity] = []
    
    init(
        router: GithubUserListWireframe,
        githubSearchUsersUseCase: GithubSearchUsersUseCase
    ) {
        self.router = router
        self.githubSearchUsersUseCase = githubSearchUsersUseCase
    }
    
    func search() {
        guard !searchInput.isEmpty else { return }
        isLoading = true
        searchingInput = searchInput
        resetRequestState()
        let request = GithubSearchUsersRequest(q: searchingInput, page: page)
        Task {
            let res = await githubSearchUsersUseCase.search(request: request)
            await MainActor.run {
                isLoading = false
                switch res {
                case .success(let data):
                    userEntities = data.items
                    canLoadMore = calculateCanLoadMore(response: data.items)
                case .failure:
                    break
                }
            }
        }
    }
    
    func loadMore() {
        page += 1
        let request = GithubSearchUsersRequest(q: searchingInput, page: page)
        isLoading = true
        Task {
            let res = await githubSearchUsersUseCase.search(request: request)
            await MainActor.run {
                isLoading = false
                switch res {
                case .success(let data):
                    userEntities.append(contentsOf: data.items)
                    canLoadMore = calculateCanLoadMore(response: data.items)
                case .failure:
                    break
                }
            }
        }
    }
    
    private func resetRequestState() {
        page = 1
        canLoadMore = false
        userEntities = []
    }
    
    private func calculateCanLoadMore(
        response: [GithubSearchUserEntity]
    ) -> Bool {
        return response.count > .zero
    }
    
    func getUserEntity(index: Int) -> GithubSearchUserEntity? {
        guard 0..<userEntities.count ~= index else { return nil }
        return userEntities[index]
    }
}
