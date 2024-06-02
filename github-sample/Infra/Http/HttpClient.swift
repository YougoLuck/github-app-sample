//
//  HttpClient.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation
import Alamofire

/// 汎用的リクエストパラメーター
typealias HttpParameters = [String: Any]

/// 汎用的リクエストヘッダー
typealias HttpHeader = [String: String]

/// リクエスト前処理エラー
enum HttpClientError: Int, LocalizedError {
    case urlInitialize = 8000
    case urlEncode = 8001

    var errorDescription: String? {
        switch self {
        case .urlInitialize:
            return "Http Client URL initialize failed."
        case .urlEncode:
            return "Http Client URL paramaters encode failed."
        }
    }
}

protocol HttpClientProtocol {
    func get(
        url: String,
        header: HttpHeader?,
        params: HttpParameters?,
        emptyResCodes: Set<Int>?
    ) async -> HttpResponse
    
    func post(
        url: String,
        header: HttpHeader?,
        params: HttpParameters?,
        emptyResCodes: Set<Int>?
    ) async -> HttpResponse
    func patch(
        url: String,
        header: HttpHeader?,
        params: HttpParameters?,
        emptyResCodes: Set<Int>?
    ) async -> HttpResponse
    
    func delete(
        url: String,
        header: HttpHeader?,
        params: HttpParameters?,
        emptyResCodes: Set<Int>?
    ) async -> HttpResponse
}

/// 汎用的APIレスポンス
struct HttpResponse {
    var url: String
    var params: HttpParameters?
    var statusCode: Int?
    var data: Data?
    var json: Any?
    var error: Error?
}

final class HttpClient: HttpClientProtocol {
    /// シングルトンインスタンス
    static let client = HttpClient()
    /// セッション
    private let session = Alamofire.Session()
    
    private init() {}
    
    /// ヘッダーを変換
    /// - Parameter header: ヘッダー
    /// - Returns: 変換後のヘッダー
    private func convert(header: HttpHeader?) -> HTTPHeaders? {
        if let header = header {
            return HTTPHeaders(header)
        } else {
            return nil
        }
    }
    
    /// Get用のURLとパラメータをエンコード
    /// - Parameters:
    ///   - url: URL
    ///   - params: パラメータ
    /// - Returns: エンコードURL
    private func encodeURL(
        url: String, 
        params: HttpParameters?
    ) throws -> String {
        // URL文字列用のエンコード
        guard let percentEncodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw HttpClientError.urlEncode
        }
        
        // 引数のURL文字列をURLオブジェクトに変換
        guard let urlObject = URL(string: percentEncodedUrl) else {
            throw HttpClientError.urlInitialize
        }
        // パラメータを含めてエンコード
        var encodedUrl: String
        do {
            // エンコード
            let request = try Alamofire.URLEncoding(destination: .queryString).encode(URLRequest(url: urlObject), with: params)
            // URL取り出し
            if let urlString = request.url?.absoluteString {
                encodedUrl = urlString
            } else {
                throw HttpClientError.urlEncode
            }
            // クエリ内の ? / をエンコード文字に置換
            if let query = request.url?.query {
                let encodedQuery = query.replacingOccurrences(of: "/", with: "%2f").replacingOccurrences(of: "?", with: "%3f")
                encodedUrl = encodedUrl.replacingOccurrences(of: query, with: encodedQuery)
            }
        } catch let error {
            throw error
        }
        
        return encodedUrl
    }
    
    /// HTTP-GETメソッド
    /// - Parameters:
    ///   - url: url
    ///   - header: ヘッダー
    ///   - params: パラメータ
    ///   - emptyResCodes: 空レスポンスを許可するステータスコード
    /// - Returns: レスポンス
    func get(
        url: String,
        header: HttpHeader?,
        params: HttpParameters?,
        emptyResCodes: Set<Int>?
    ) async -> HttpResponse {
        
        let percentEncodedUrl: String
        do {
            percentEncodedUrl = try encodeURL(url: url, params: params)
        } catch let error {
            return HttpResponse(url: url, error: error)
        }
        var result = await request(method: .get, url: percentEncodedUrl, header: header, params: nil, emptyResCodes: emptyResCodes)
        result.params = params
        return result
    }
    
    /// HTTP-POSTメソッド
    /// - Parameters:
    ///   - url: url
    ///   - header: ヘッダー
    ///   - params: パラメータ
    ///   - emptyResCodes: 空レスポンスを許可するステータスコード
    /// - Returns: レスポンス
    func post(
        url: String,
        header: HttpHeader?,
        params: HttpParameters?,
        emptyResCodes: Set<Int>?
    ) async -> HttpResponse {
        
        return await request(method: .post, url: url, header: header, params: params, emptyResCodes: emptyResCodes)
    }
    
    /// HTTP-PATCHメソッド
    /// - Parameters:
    ///   - url: url
    ///   - header: ヘッダー
    ///   - params: パラメータ
    ///   - emptyResCodes: 空レスポンスを許可するステータスコード
    /// - Returns: レスポンス
    func patch(
        url: String,
        header: HttpHeader?,
        params: HttpParameters?,
        emptyResCodes: Set<Int>?
    ) async -> HttpResponse {
        
        return await request(method: .patch, url: url, header: header, params: params, emptyResCodes: emptyResCodes)
    }
    
    /// HTTP-DELETEメソッド
    /// - Parameters:
    ///   - url: url
    ///   - header: ヘッダー
    ///   - params: パラメータ
    ///   - emptyResCodes: 空レスポンスを許可するステータスコード
    /// - Returns: レスポンス
    func delete(
        url: String,
        header: HttpHeader?,
        params: HttpParameters?, 
        emptyResCodes: Set<Int>?
    ) async -> HttpResponse {
        
        return await request(method: .delete, url: url, header: header, params: params, emptyResCodes: emptyResCodes)
    }
    
    /// 共通のHTTPリクエストロジック
    /// - Parameters:
    ///   - method: method
    ///   - url: url
    ///   - header: ヘッダー
    ///   - params: パラメータ
    ///   - emptyResCodes: 空レスポンスを許可するステータスコード
    /// - Returns: レスポンス
    private func request(
        method: HTTPMethod,
        url: String,
        header: HttpHeader?,
        params: HttpParameters?,
        emptyResCodes: Set<Int>?
    ) async -> HttpResponse {
        
        // ヘッダーをリクエスト用のオブジェクトに変換
        let httpHeaders = convert(header: header)
        // HTTPリクエスト
        let httpResponse: HttpResponse
        do {
            httpResponse = try await withCheckedThrowingContinuation { continuation in
                var emptyCodes = DataResponseSerializer.defaultEmptyResponseCodes
                emptyResCodes?.forEach { emptyCodes.insert($0) }
                session.request(
                    url,
                    method: method,
                    parameters: params,
                    encoding: JSONEncoding.default,
                    headers: httpHeaders
                ).responseData(emptyResponseCodes: emptyCodes) { response in
                    if let error = response.error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: HttpResponse(
                            url: url,
                            params: params,
                            statusCode: response.response?.statusCode,
                            data: response.data,
                            json: try? JSONSerialization.jsonObject(with: response.data ?? Data())
                        ))
                    }
                }
            }
        } catch let error {
            httpResponse = HttpResponse(url: url,
                                        params: params,
                                        error: error)
        }
        return httpResponse
    }
}
