//
//  GithubUserDetailUseCase.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation

protocol GithubUserDetailUseCase {
    func get(userID: String) async -> GithubApiResponse<GithubUserDetailEntity>
}

class GithubUserDetailInteractor: GithubUserDetailUseCase, GithubRequestHelper {
    private let httpClient: HttpClientProtocol
    
    init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }
    
    func get(userID: String) async -> GithubApiResponse<GithubUserDetailEntity> {
        let url = createUrl(path: "/users/\(userID)")
        let res = await httpClient.get(
            url: url,
            header: createHeader(),
            params: nil,
            emptyResCodes: nil
        )
        return decodedResult(type: GithubUserDetailEntity.self, response: res)
    }
}
