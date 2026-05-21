//
//  APIClient.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/16/26.
//

import Foundation

extension Notification.Name {
    static let didReceiveUnauthorizedResponse = Notification.Name("didReceiveUnauthorizedResponse")
    static let didUpdateProduct = Notification.Name("didUpdateProduct")
}

struct MultipartFile {
    let fieldName: String
    let fileName: String
    let mimeType: String
    let data: Data
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized(message: String)
    case server(statusCode: Int, message: String)
    case decodingFailure

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "서버 주소가 올바르지 않습니다."
        case .invalidResponse:
            return "서버 응답을 확인할 수 없습니다."
        case let .unauthorized(message):
            return message
        case let .server(_, message):
            return message
        case .decodingFailure:
            return "응답 데이터를 처리하는 중 문제가 발생했습니다."
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let baseURLString: String
    private let tokenStore: TokenStoreProtocol

    init(
        session: URLSession = .shared,
        baseURLString: String = "https://reactproject-q472.onrender.com/api",
        tokenStore: TokenStoreProtocol = KeychainTokenStore()
    ) {
        self.session = session
        self.baseURLString = baseURLString
        self.tokenStore = tokenStore
    }

    func post<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String,
        body: RequestBody,
        bearerToken: String? = nil
    ) async throws -> ResponseBody {
        let (data, _) = try await sendPost(path: path, body: body, bearerToken: bearerToken)
        do {
            return try JSONDecoder().decode(ResponseBody.self, from: data)
        } catch {
            throw NetworkError.decodingFailure
        }
    }

    func postNoResponse<RequestBody: Encodable>(
        path: String,
        body: RequestBody,
        bearerToken: String? = nil
    ) async throws {
        _ = try await sendPost(path: path, body: body, bearerToken: bearerToken)
    }
    
    func postFormNoResponse(
        path: String,
        form: [String: String],
        bearerToken: String? = nil
    ) async throws {
        guard let url = URL(string: baseURLString + path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        if let bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        } else if !isAuthEndpoint(path), let savedToken = tokenStore.readToken() {
            request.setValue("Bearer \(savedToken)", forHTTPHeaderField: "Authorization")
        }
        
        var components = URLComponents()
        components.queryItems = form.map { URLQueryItem(name: $0.key, value: $0.value) }
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        
        let (data, response) = try await session.data(for: request)
        _ = try handleResponse(data: data, response: response, path: path)
    }

    func get<ResponseBody: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        bearerToken: String? = nil
    ) async throws -> ResponseBody {
        let (data, _) = try await sendGet(path: path, queryItems: queryItems, bearerToken: bearerToken)
        do {
            return try JSONDecoder().decode(ResponseBody.self, from: data)
        } catch {
            throw NetworkError.decodingFailure
        }
    }

    private func sendPost<RequestBody: Encodable>(
        path: String,
        body: RequestBody,
        bearerToken: String?
    ) async throws -> (Data, HTTPURLResponse) {
        guard let url = URL(string: baseURLString + path) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        } else if !isAuthEndpoint(path), let savedToken = tokenStore.readToken() {
            request.setValue("Bearer \(savedToken)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        return try handleResponse(data: data, response: response, path: path)
    }

    private func sendGet(
        path: String,
        queryItems: [URLQueryItem],
        bearerToken: String?
    ) async throws -> (Data, HTTPURLResponse) {
        guard var components = URLComponents(string: baseURLString + path) else {
            throw NetworkError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        } else if !isAuthEndpoint(path), let savedToken = tokenStore.readToken() {
            request.setValue("Bearer \(savedToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        return try handleResponse(data: data, response: response, path: path)
    }

    private func handleResponse(
        data: Data,
        response: URLResponse,
        path: String
    ) throws -> (Data, HTTPURLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if (200...299).contains(httpResponse.statusCode) {
            return (data, httpResponse)
        }

        let errorMessage = parseErrorMessage(from: data)

        if httpResponse.statusCode == 401 {
            try? tokenStore.deleteToken()
            if !isAuthEndpoint(path) {
                NotificationCenter.default.post(name: .didReceiveUnauthorizedResponse, object: nil)
            }
            throw NetworkError.unauthorized(message: errorMessage ?? "인증이 만료되었습니다. 다시 로그인해 주세요.")
        }

        throw NetworkError.server(
            statusCode: httpResponse.statusCode,
            message: errorMessage ?? "요청을 처리하지 못했습니다."
        )
    }

    private func isAuthEndpoint(_ path: String) -> Bool {
        path == "/users/login" || path == "/users/join"
    }

    private func parseErrorMessage(from data: Data) -> String? {
        guard let errorResponse = try? JSONDecoder().decode(ApiErrorResponse.self, from: data) else {
            return nil
        }
        return errorResponse.fieldErrors?.values.first ?? errorResponse.message
    }
    
    func delete(path: String, bearerToken: String? = nil) async throws {
        guard let url = URL(string: baseURLString + path) else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        } else if !isAuthEndpoint(path), let savedToken = tokenStore.readToken() {
            request.setValue("Bearer \(savedToken)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        _ = try handleResponse(data: data, response: response, path: path)
    }
    
    func postMultipartNoResponse(
        path: String,
        form: [String: String],
        file: MultipartFile?,
        bearerToken: String? = nil
    ) async throws {
        guard let url = URL(string: baseURLString + path) else { throw NetworkError.invalidURL }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        } else if !isAuthEndpoint(path), let savedToken = tokenStore.readToken() {
            request.setValue("Bearer \(savedToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = buildMultipartBody(form: form, file: file, boundary: boundary)
        
        let (data, response) = try await session.data(for: request)
        _ = try handleResponse(data: data, response: response, path: path)
    }
    
    private func buildMultipartBody(
        form: [String: String],
        file: MultipartFile?,
        boundary: String
    ) -> Data {
        var body = Data()
        
        for (key, value) in form {
            body.appendUTF8("--\(boundary)\r\n")
            body.appendUTF8("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendUTF8("\(value)\r\n")
        }
        
        if let file {
            body.appendUTF8("--\(boundary)\r\n")
            body.appendUTF8("Content-Disposition: form-data; name=\"\(file.fieldName)\"; filename=\"\(file.fileName)\"\r\n")
            body.appendUTF8("Content-Type: \(file.mimeType)\r\n\r\n")
            body.append(file.data)
            body.appendUTF8("\r\n")
        }
        
        body.appendUTF8("--\(boundary)--\r\n")
        return body
    }
}

private extension Data {
    mutating func appendUTF8(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
