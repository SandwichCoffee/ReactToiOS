//
//  AuthServiceProtocol.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/15/26.
//

import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws
    func register(email: String, password: String, userName: String) async throws
    func readSavedToken() -> String?
    func logout() throws
}
