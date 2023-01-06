//
//  LoginViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/06.
//

import Foundation

final class LoginViewModel: ObservableObject {
    
    @Published var id: String
    @Published var password: String
    
    init(id: String = "", password: String = "") {
        self.id = id
        self.password = password
    }
}
