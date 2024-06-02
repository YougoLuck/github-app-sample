//
//  GithubSearchUsersUseCase.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation

struct GithubSearchUsersRequest: Codable {
    let q: String
    let page: Int
}

protocol GithubSearchUsersUseCase {
    func search(request: GithubSearchUsersRequest) async -> GithubApiResponse<GithubSearchUserApiResponse>
}

final class GithubSearchUsersInteractor: GithubSearchUsersUseCase, GithubRequestHelper {
    private let httpClient: HttpClientProtocol
    
    private let apiPath = "/search/users"
    
    init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }
    
    func search(request: GithubSearchUsersRequest) async -> GithubApiResponse<GithubSearchUserApiResponse> {
        let url = createUrl(path: apiPath)
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
        return decodedResult(type: GithubSearchUserApiResponse.self, response: res)
    }
}
