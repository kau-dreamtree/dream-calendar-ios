//
//  LoginViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/06.
//

import Foundation

final class LoginViewModel: ObservableObject {
    
    @Published var email: String
    @Published var password: String
    @Published var didLogin: Bool?
    @Published var didError: Bool
    private(set) var loginMessage: String?
    private(set) var error: Error?
    
    init(email: String = "", password: String = "") {
        self.email = email
        self.password = password
        self.didLogin = nil
        self.didError = false
        self.loginMessage = nil
        self.error = nil
    }
    
    @MainActor
    func login() async -> Bool {
        let apiInfo = DCAPI.Account.login(email: email, password: password)
        do {
            let (statusCode, data) = try await DCRequest().request(with: apiInfo)
            switch statusCode {
            case 200 :
                if let response = try apiInfo.response(data) as? DCAPI.Account.LoginResponse {
                    self.saveLoginResponse(response)
                }
                return true
            case 404 :
                self.loginMessage = "이메일 또는 비밀번호가 틀렸습니다."
                self.didLogin = true
            default :
                throw DCError.serverError
            }
        } catch let error where error is DCError {
            guard let dcError = error as? DCError else { return false }
            self.loginMessage = dcError.message
            self.didLogin = false
        } catch {
            self.error = error
            self.didError = true
            self.didLogin = nil
        }
        return false
    }
    
    private func saveLoginResponse(_ data: DCAPI.Account.LoginResponse) {
        User.global.accessToken = data.access_token
        User.global.refreshToken = data.refresh_token
    }
}
