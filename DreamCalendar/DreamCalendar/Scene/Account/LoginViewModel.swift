//
//  LoginViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/06.
//

import Foundation
import CoreData

final class LoginViewModel: ObservableObject {
    
    @Published var email: String
    @Published var password: String
    @Published var didError: Bool
    @Published private(set) var loginMessage: String?
    private(set) var error: Error?
    private let scheduleManager: ScheduleManager
    
    init(email: String = "", password: String = "", scheduleManager: ScheduleManager) {
        self.email = email
        self.password = password
        self.didError = false
        self.loginMessage = nil
        self.error = nil
        self.scheduleManager = scheduleManager
    }
    
    @MainActor
    func login() async {
        do {
            try await AccountManager.global.login(email: self.email, password: self.password, scheduleManager: self.scheduleManager)
            if AccountManager.global.didLogin == false {
                self.loginMessage = "이메일 또는 비밀번호가 틀렸습니다."
            }
        } catch let error where error is DCError {
            guard let dcError = error as? DCError else { return }
            self.loginMessage = dcError.message
        } catch {
            self.error = error
            self.didError = true
        }
    }
    
    func resetLoginStatus() {
        self.error = nil
        self.didError = false
        self.loginMessage = nil
    }
}
