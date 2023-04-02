//
//  DeveloperSetting.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/03/23.
//

import Foundation

#if DEVELOP
final class DeveloperConfiguration {
    
    static let global: DeveloperConfiguration = DeveloperConfiguration()
    
    private(set) var loginSetting: LoginSetting = LoginSetting()
    
    private init() {}
    
    struct LoginSetting {
        private struct Keys {
            static let accessTokenTest = "accessTokenTest"
            static let refreshTokenTest = "refreshTokenTest"
        }
        
        var accessTokenTest: Bool {
            get {
                return UserDefaults.standard.bool(forKey: Keys.accessTokenTest)
            }
            set {
                UserDefaults.standard.set(newValue, forKey: Keys.accessTokenTest)
            }
        }
        
        var refreshTokenTest: Int {
            get {
                return UserDefaults.standard.integer(forKey: Keys.refreshTokenTest)
            }
            set {
                UserDefaults.standard.set(newValue, forKey: Keys.refreshTokenTest)
            }
        }
    }
    
    func testAccessToken(isOn: Bool) {
        self.loginSetting.accessTokenTest = isOn
    }
    
    func testRefreshToken(_ mode: Int) {
        self.loginSetting.refreshTokenTest = mode
    }
}
#endif
