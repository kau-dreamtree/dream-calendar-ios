//
//  SignupViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/03.
//

import Foundation

final class SignupViewModel: ObservableObject {
    @Published var name: String
    @Published var email: String
    @Published var password: String
    @Published var passwordCheck: String
    @Published var didSignup: Bool
    @Published var didError: Bool
    
    private(set) var signupMessage: String?
    private(set) var error: Error?
    
    init() {
        self.name = ""
        self.email = ""
        self.password = ""
        self.passwordCheck = ""
        self.didSignup = false
        self.didError = false
        
        self.signupMessage = nil
        self.error = nil
    }
    
    @MainActor
    func singup() {
        Task {
            do {
                try checkFormat()
                
                let signupResult = try await AccountManager.global.signup(email: self.email,
                                                                          password: self.password,
                                                                          name: self.name)
                switch signupResult {
                case true :
                    self.didSignup = true
                case false :
                    self.signupMessage = "이미 등록된 이메일입니다."
                    self.didSignup = false
                }
            } catch let error where error is SignUpFormatError{
                if let formatError = error as? SignUpFormatError {
                    self.signupMessage = formatError.message
                    self.didSignup = false
                } else {
                    self.error = error
                    self.didError = true
                }
            } catch {
                self.error = error
                self.didError = true
            }
        }
    }
    
    private func checkFormat() throws {
        if self.name.isEmpty {
            throw SignUpFormatError.emptyNameField
        } else if self.email.isEmpty {
            throw SignUpFormatError.emptyEmailField
        } else if self.password.isEmpty {
            throw SignUpFormatError.emptyPasswordField
        } else if self.passwordCheck.isEmpty {
            throw SignUpFormatError.emptyPasswordkCheckField
        } else if self.password != self.passwordCheck {
            throw SignUpFormatError.passwordCheckNotMatching
        }
        return
    }
    
    private enum SignUpFormatError: Error {
        case emptyNameField, emptyEmailField, emptyPasswordField, emptyPasswordkCheckField, passwordCheckNotMatching
        
        var message: String {
            let field: String?
            switch self {
            case .emptyNameField : field = "이름"
            case .emptyEmailField : field = "이메일"
            case .emptyPasswordField : field = "비밀번호"
            case .emptyPasswordkCheckField : field = "비밀번호 확인"
            case .passwordCheckNotMatching : field = nil
            }
            if let field = field {
                return "\(field)란을 채워주세요."
            } else {
                return "비밀번호와 비밀번호 확인이 일치하지 않습니다."
            }
        }
    }
}
