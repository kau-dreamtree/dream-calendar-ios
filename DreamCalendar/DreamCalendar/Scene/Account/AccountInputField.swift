//
//  AccountInputField.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/06.
//

import SwiftUI

fileprivate struct Constraint {
    static let height: CGFloat = 53
    static let width: CGFloat = 264
    static let titleHeight: CGFloat = 23
    static let titleWidth: CGFloat = 60
    static let inputFieldTopPadding: CGFloat = 10
    static let lineHeight: CGFloat = 0.5
    static let zeroPadding: CGFloat = 0
}

struct AccountInputField<InputField: InputableField>: View {
    
    private let fieldName: String
    @Binding private(set) var inputValue: String
    
    init(fieldName: String, inputValue: Binding<String>) {
        self.fieldName = fieldName
        self._inputValue = inputValue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(self.fieldName)
                .font(.AppleSDSemiBold12)
                .frame(height: Constraint.titleHeight)
            
            InputField.init("", text: self.$inputValue)
                .textInputAutocapitalization(.never)
                .font(.AppleSDBold12)
                .padding(EdgeInsets(top: Constraint.inputFieldTopPadding,
                                    leading: Constraint.zeroPadding,
                                    bottom: Constraint.zeroPadding,
                                    trailing: Constraint.zeroPadding))
            
            Divider()
                .overlay(Color.black)
                .frame(minWidth: Constraint.lineHeight)
        }
        .frame(width: Constraint.width, height: Constraint.height)
    }
}

enum InputFieldType: CaseIterable {
    case name, email, password, passwordCheck
    
    var name: String {
        switch self {
        case .name : return "사용자 이름"
        case .email : return "이메일"
        case .password : return "비밀번호"
        case .passwordCheck : return "비밀번호 확인"
        }
    }
    
    private var needSecurity: Bool {
        switch self {
        case .name, .email : return false
        case .password, .passwordCheck : return true
        }
    }
    
    @ViewBuilder
    func fieldView(with inputValue: Binding<String>) -> some View {
        switch self.needSecurity {
        case true: AccountInputField<SecureField<Text>>(fieldName: self.name, inputValue: inputValue)
        case false: AccountInputField<TextField<Text>>(fieldName: self.name, inputValue: inputValue)
        }
    }
}
