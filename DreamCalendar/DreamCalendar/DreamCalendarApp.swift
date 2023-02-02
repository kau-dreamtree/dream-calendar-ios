//
//  DreamCalendarApp.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/10/03.
//

import SwiftUI

struct User {
    
    static var global: User = User()
    
    private init() {}
    
    private struct Keys {
        static let accessTokenKey = "accessToken"
        static let refreshTokenKey = "refreshToken"
        static let username = "username"
        static let email = "email"
        static let password = "password"
    }
    
    var didSetAutoLogin: Bool {
        let autoLoginKey = "autoLogin"
        return UserDefaults.standard.bool(forKey: autoLoginKey)
    }
    
    var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.accessTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.accessTokenKey)
        }
    }
    
    var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.refreshTokenKey)
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
}

@main
struct DreamCalendarApp: App {
    let persistenceController = PersistenceController.shared
    @State private var didLogin: Bool? = nil
    @State private var error: Error? = nil
    

    var body: some Scene {
        WindowGroup {
            switch self.didLogin {
            case true :
                MainView(viewModel: MainViewModel(self.persistenceController.container.viewContext))
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            case false :
                LoginView(viewModel: LoginViewModel(), didLogin: self.$didLogin)
            default :
                ActivityIndicator(isAnimating: self.$didLogin, style: .large)
                    .onAppear(perform: self.startAutoLogin)
            }
        }
    }
    
    private func startAutoLogin() {
        let user = User.global
        guard User.global.didSetAutoLogin == true,
              let accessToken = user.accessToken else {
            self.didLogin = false
            return
        }
        presentFirstPage(accessToken: accessToken)
    }
    
    private func presentFirstPage(accessToken: String) {
        let apiInfo = DCAPI.Account.tokenLogin(authorization: accessToken)
        
        Task {
            do {
                let (statusCode, _) = try await DCRequest().request(with: apiInfo)
                switch statusCode {
                case 200 : self.didLogin = true
                default : self.didLogin = false
                }
            } catch {
                self.error = error
            }
        }
    }
}

fileprivate struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool?
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: self.style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        self.isAnimating == nil ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
