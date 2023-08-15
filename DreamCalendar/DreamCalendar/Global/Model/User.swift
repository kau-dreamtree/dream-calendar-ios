//
//  User.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/02.
//

import Foundation

struct User {
    
    private struct Keys {
        static let accessTokenKey = "accessToken"
        static let refreshTokenKey = "refreshToken"
        static let username = "username"
        static let email = "email"
        static let password = "password"
    }
    
    var accessToken: String? {
        get {
            guard let token = UserDefaults.standard.string(forKey: Keys.accessTokenKey) else { return nil }
            return "Bearer \(token)"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.accessTokenKey)
        }
    }
    
    var refreshToken: String? {
        get {
            guard let token = UserDefaults.standard.string(forKey: Keys.refreshTokenKey) else { return nil }
            return "Bearer \(token)"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.refreshTokenKey)
        }
    }
    
    var username: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.username)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.username)
        }
    }
    
    var email: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.email)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.email)
        }
    }
    
    var password: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.password)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.password)
        }
    }
    
    mutating func reset() {
        self.email = nil
        self.password = nil
        self.username = nil
        self.resetToken()
    }
    
    mutating func resetToken() {
        self.refreshToken = nil
        self.accessToken = nil
    }
}
