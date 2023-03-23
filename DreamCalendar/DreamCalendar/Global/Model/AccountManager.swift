//
//  AccountManager.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/03/09.
//

import Foundation
import Combine

final class AccountManager: ObservableObject {
    
    static let global = AccountManager()
    
    @Published private(set) var didLogin: Bool? = nil
    
    private(set) var user: User
    
    private init() {
        self.user = User()
    }
    
    @MainActor
    func tokenLogin() async throws {
        guard let accessToken = self.user.accessToken else {
            self.didLogin = false
            return
        }
        let apiInfo = DCAPI.Account.tokenLogin(authorization: accessToken)
        
        let (statusCode, _) = try await DCRequest().request(with: apiInfo)
        switch statusCode {
        case 200 :
            self.didLogin = true
        case 401 :
            try await refreshToken()
        default :
            self.user.accessToken = nil
            self.user.refreshToken = nil
            self.didLogin = false
        }
    }
    
    @MainActor
    private func refreshToken() async throws {
        guard let refreshToken = self.user.refreshToken else {
            self.didLogin = false
            return
        }
        let apiInfo = DCAPI.Account.refreshToken(refreshToken: refreshToken)
        
        let (statusCode, data) = try await DCRequest().request(with: apiInfo)
        switch statusCode {
        case 200 :
            if let response = try apiInfo.response(data) as? DCAPI.Account.Response {
                self.user.accessToken = response.access_token
                self.user.refreshToken = response.refresh_token
                self.didLogin = true
            }
        default :
            self.user.accessToken = nil
            self.user.refreshToken = nil
            self.didLogin = false
        }
    }
    
    @MainActor
    func signup(email: String, password: String, name: String) async throws -> Bool {
        let apiInfo = DCAPI.Account.signup(email: email,
                                           password: password,
                                           name: name)
        let (statusCode, _) = try await DCRequest().request(with: apiInfo)
        switch statusCode {
        case 201 :
            return true
        case 409 :
            return false
        default :
            throw DCError.serverError
        }
    }
    
    @MainActor
    func login(email: String, password: String) async throws {
        let apiInfo = DCAPI.Account.login(email: email, password: password)
        let (statusCode, data) = try await DCRequest().request(with: apiInfo)
        
        switch statusCode {
        case 200 :
            if let response = try apiInfo.response(data) as? DCAPI.Account.Response {
                self.user.accessToken = response.access_token
                self.user.refreshToken = response.refresh_token
            }
            self.didLogin = true
        case 404 :
            break
        default :
            throw DCError.serverError
        }
    }
    
    func logout() async throws {
        guard let accessToken = self.user.accessToken else { throw DCError.accountError }
        let apiInfo = DCAPI.Account.logout(authorization: accessToken)
        let _ = try await DCRequest().request(with: apiInfo)
        
        self.user.reset()
        self.didLogin = false
    }
}
