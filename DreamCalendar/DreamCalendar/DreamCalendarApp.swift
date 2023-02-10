//
//  DreamCalendarApp.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/10/03.
//

import SwiftUI

@main
struct DreamCalendarApp: App {
    let persistenceController = PersistenceController.shared
    
    @State private var didLogin: Bool? = nil
    @State private var didError: Bool = false
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
                    .alert(DCError.title, isPresented: self.$didError) {
                        Button("재시도") {
                            self.didError = false
                            self.startAutoLogin()
                        }
                    } message : {
                        Text((self.error as? DCError)?.message ?? Alert.failMessage)
                    }
                    .onAppear(perform: self.startAutoLogin)
            }
        }
    }
    
    private func startAutoLogin() {
        let user = User.global
        guard let accessToken = user.accessToken,
              let refreshToken = user.refreshToken else {
            self.didLogin = false
            return
        }
        do {
            try TagManager.initializeGlobalTagManager(with: self.persistenceController.container.viewContext)
            self.presentFirstPage(accessToken: accessToken, refreshToken: refreshToken)
        } catch {
            self.error = error
            self.didError = true
        }
    }
    
    private func presentFirstPage(accessToken: String, refreshToken: String) {
        let apiInfo = DCAPI.Account.tokenLogin(authorization: accessToken)
        
        Task {
            do {
                let (statusCode, _) = try await DCRequest().request(with: apiInfo)
                switch statusCode {
                case 200 : self.didLogin = true
                case 401 : self.refreshToken(refreshToken)
                default : self.didLogin = false
                }
            } catch {
                self.didError = true
                self.error = error
            }
        }
    }
    
    private func refreshToken(_ refreshToken: String) {
        let apiInfo = DCAPI.Account.refreshToken(refreshToken: refreshToken)
        
        Task {
            do {
                let (statusCode, data) = try await DCRequest().request(with: apiInfo)
                switch statusCode {
                case 200 :
                    if let response = try apiInfo.response(data) as? DCAPI.Account.Response {
                        User.global.accessToken = response.access_token
                        User.global.refreshToken = response.refresh_token
                        self.didLogin = true
                    } else {
                        self.didLogin = false
                    }
                default :
                    self.didLogin = false
                }
            } catch {
                self.didError = true
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
