//
//  SettingsView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/03/08.
//

import SwiftUI

struct SettingsView: View {
    
    private struct Constraint {
        static let navigationBarTitle: String = "설정"
        static let backButtonImageName: String = "xmark"
        
        static let logoutMessage: String = "로그아웃 하시겠습니까?"
    }
    
    @Binding private var isOpen: Bool
    @State private var didError: Bool = false
    @State private var doLogout: Bool = false
    
    init(isOpen: Binding<Bool>) {
        self._isOpen = isOpen
    }
    
    var body: some View {
        NavigationView {
            List {
                self.generalSection()
                self.accountSection()
                self.etcSection()
            }
            .navigationBarTitle(Constraint.navigationBarTitle)
            .navigationBarItems(trailing: Button(action: {
                self.isOpen = false
            }, label: {
                Image(systemName: Constraint.backButtonImageName)
                    .foregroundColor(.black)
            }))
            .alert("계정", isPresented: self.$doLogout, actions: {
                Button("확인",
                       role: .destructive,
                       action: self.logout)
                Button("취소",
                       role: .cancel,
                       action: {
                    self.doLogout = false
                })
            }, message: {
                Text(Constraint.logoutMessage)
            })
        }
    }
    
    private func generalSection() -> some View {
        let title = "일반"
        let field = "태그 목록 수정"
        
        return Section(header: Text(title)) {
            NavigationLink(field) {
                Text(field)
            }
        }
    }
    
    private func accountSection() -> some View {
        let title = "계정"
        let field = "로그아웃"
        
        return Section(header: Text(title)) {
            Button(action: {
                self.doLogout = true
            }, label: {
                Text(field)
                    .foregroundColor(.black)
            })
        }
    }
    
    private func etcSection() -> some View {
        let title = "기타"
        let fields = ["이용약관", "개인정보 처리방침"]
        
        return Section(header: Text(title)) {
            ForEach(fields, id: \.hashValue) { field in
                NavigationLink(field) {
                    Text(field)
                }
            }
        }
    }
    
    private func logout() {
        Task {
            do {
                try await AccountManager.global.logout()
            } catch {
                print(error)
            }
        }
    }
}
