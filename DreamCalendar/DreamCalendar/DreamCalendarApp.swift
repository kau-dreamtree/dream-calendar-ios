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
    
    @ObservedObject private var accountManager: AccountManager = AccountManager.global
    @State private var didError: Bool = false
    @State private var error: Error? = nil

    var body: some Scene {
        WindowGroup {
            switch self.accountManager.didLogin {
            case true :
                MainView(viewModel: MainViewModel(self.persistenceController.container.viewContext))
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            case false :
                LoginView(viewModel: LoginViewModel())
            default :
                ActivityIndicator(isAnimating: Binding<Bool?>(get: { return nil }, set: { _, _ in }), style: .large)
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
        do {
            try TagManager.initializeGlobalTagManager(with: self.persistenceController.container.viewContext)
            self.presentFirstPage()
        } catch {
            self.error = error
            self.didError = true
        }
    }
    
    private func presentFirstPage() {
        Task {
            do {
                try await AccountManager.global.tokenLogin()
            } catch {
                self.error = error
                self.didError = true
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
