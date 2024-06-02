//
//  GithubRequestHelper.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation

enum GithubApiResponse<T> {
    case success(T)
    case failure(GithubApiResponseFailure)
}

struct GithubApiResponseFailure {
    let url: String
    let params: HttpParameters?
    let statusCode: Int?
    let error: Error?
    let json: Any?
}

enum GithubClientError: Int, LocalizedError {
    case paramEncode = 9000
    case responseDecode = 9001
    
    var errorDescription: String? {
        switch self {
        case .paramEncode:
            return "Github api paramaters encode failed."
        case .responseDecode:
            return "Github api response decode failed."
        }
    }
}

fileprivate struct GithubRequestResource {
    struct Version {
        static let key = "X-GitHub-Api-Version"
        static let value = "2022-11-28"
    }
    
    struct Authentication {
        static let key = "Authorization"
        static let value = "Bearer"
    }
    
    static let token = "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"
    static let baseUrl = "https://api.github.com"
}

protocol GithubRequestHelper {
    func createHeader() -> HttpHeader
    
    func createUrl(path: String) -> String
    
    func encode<T: Encodable>(request: T) throws -> HttpParameters
    
    func decodedResult<T: Codable>(
        type: T.Type,
        response: HttpResponse
    ) throws -> GithubApiResponse<T>
}

extension GithubRequestHelper {
    /// ヘッダーを作成
    /// - Parameter token: Githubのトークン
    /// - Returns: リクエスト用のヘッダー
    func createHeader() -> HttpHeader {
        var header = [GithubRequestResource.Version.key: GithubRequestResource.Version.value]
        header[GithubRequestResource.Authentication.key] = "\(GithubRequestResource.Authentication.value) \(GithubRequestResource.token)"
        return header
    }
    
    /// URLを作成
    /// - Parameter path: API Path
    /// - Returns: URL
    func createUrl(path: String) -> String {
        return GithubRequestResource.baseUrl + path
    }
    
    /// パラメータをJSONエンコード
    /// - Parameter request: モデル
    /// - Returns: JSONパラメータ
    func encode<T: Encodable>(request: T) throws -> HttpParameters {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let requestData = try? encoder.encode(request),
              let paramters = try? JSONSerialization.jsonObject(with: requestData, options: []),
              let paramters = paramters as? HttpParameters else {
            throw GithubClientError.paramEncode
        }
        return paramters
    }
    
    /// UseCase用の返却値を作成（モデル型）
    /// - Parameter response: レスポンス
    /// - Returns: UseCase用の返却値
    func decodedResult<T: Codable>(type: T.Type, response: HttpResponse) -> GithubApiResponse<T> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let data = response.data,
              let res = try? decoder.decode(type, from: data) else {
            return .failure(
                GithubApiResponseFailure(
                    url: response.url,
                    params: response.params,
                    statusCode: response.statusCode,
                    error: GithubClientError.responseDecode,
                    json: response.json
                )
            )
        }
        
        return .success(res)
    }
}
