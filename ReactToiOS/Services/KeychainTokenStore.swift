//
//  KeychainTokenStore.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/16/26.
//

import Foundation
import Security

protocol TokenStoreProtocol {
    func saveToken(_ token: String) throws
    func readToken() -> String?
    func deleteToken() throws
}

enum TokenStoreError: LocalizedError {
    case saveFailed
    case deleteFailed
    case invalidTokenData

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "토큰 저장에 실패했습니다."
        case .deleteFailed:
            return "토큰 삭제에 실패했습니다."
        case .invalidTokenData:
            return "토큰 데이터를 읽을 수 없습니다."
        }
    }
}

final class KeychainTokenStore: TokenStoreProtocol {
    private let service = "com.reacttoios.auth"
    private let account = "accessToken"

    func saveToken(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw TokenStoreError.invalidTokenData
        }

        let query = baseQuery()
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw TokenStoreError.saveFailed
        }
    }

    func readToken() -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }

        guard let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func deleteToken() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw TokenStoreError.deleteFailed
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
