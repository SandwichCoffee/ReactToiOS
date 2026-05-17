//
//  AuthModels.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/16/26.
//

import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let userName: String
}

struct LoginResponse: Decodable {
    let userId: String
    let userName: String
    let email: String
    let role: String
    let token: String
    let createdAt: String?
}

struct ApiErrorResponse: Decodable {
    let timestamp: String?
    let status: Int
    let error: String?
    let message: String
    let path: String?
    let fieldErrors: [String: String]?
}
