//
//  GithubUserRepositoryUseCase.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation

struct GithubUserRepositoryRequest: Codable {
    let page: Int
}

protocol GithubUserRepositoryUseCase {
    func get(userID: String, request: GithubUserRepositoryRequest) async -> GithubApiResponse<[GithubRepositoryEntity]>
}

class GithubUserRepositoryInteractor: GithubUserRepositoryUseCase, GithubRequestHelper {
    private let httpClient: HttpClientProtocol
    
    init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }
    
    func get(userID: String, request: GithubUserRepositoryRequest) async -> GithubApiResponse<[GithubRepositoryEntity]> {
        let url = createUrl(path: "/users/\(userID)/repos")
        let params: HttpParameters
        do {
            params = try encode(request: request)
        } catch let error {
            return .failure(
                GithubApiResponseFailure(
                    url: url,
                    params: nil,
                    statusCode: nil,
                    error: error,
                    json: nil
                )
            )
        }
        let res = await httpClient.get(
            url: url,
            header: createHeader(),
            params: params,
            emptyResCodes: nil
        )
        return decodedResult(type: [GithubRepositoryEntity].self, response: res)
    }
}
