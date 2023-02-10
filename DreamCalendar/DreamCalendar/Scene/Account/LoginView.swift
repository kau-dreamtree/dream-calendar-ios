//
//  LoginView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/03.
//

import SwiftUI


protocol InputableField: View {
    init(_ titleKey: LocalizedStringKey, text: Binding<String>)
}

extension SecureField: InputableField where Label == Text { }
extension TextField: InputableField where Label == Text { }

struct LoginView: View {
    
    private struct Constraint {
        static let imageName: String = "Logo"
        static let imageTopPadding: CGFloat = 38
        static let imageHeight: CGFloat = 146
        static let imageWidth: CGFloat = 214
        static let zeroPadding: CGFloat = 0
        
        static let inputFieldTopPadding: CGFloat = 110
        static let inputFieldHeight: CGFloat = 127
        
        static let buttonName: String = "로그인"
        static let buttonTopPadding: CGFloat = 34
        
        static let findIdPwButtonName: String = "아이디/비밀번호 찾기"
        static let signUpButtonName: String = "회원가입"
        
        static let accountOptionButtonsTopPadding: CGFloat = 8
        static let accountOptionButtonsHeight: CGFloat = 25
        static let accountOptionButtonsWidth: CGFloat = 264
    }
    
    private struct SmallTextButton: View {
        
        private struct Constraint {
            static let zeroPadding: CGFloat = 0
            static let leadingTrailingPadding: CGFloat = 4
            static let lineHeight: CGFloat = 12
        }
        
        private var title: String
        private var action: () -> Void
        
        init(title: String, action: @escaping () -> Void) {
            self.title = title
            self.action = action
        }
        
        var body: some View {
            Button(action: self.action) {
                Text(self.title)
                    .font(.AppleSDRegular10)
                    .foregroundColor(.black)
                    .lineSpacing(Constraint.lineHeight)
            }
            .padding(EdgeInsets(top: Constraint.zeroPadding,
                                leading: Constraint.leadingTrailingPadding,
                                bottom: Constraint.zeroPadding,
                                trailing: Constraint.leadingTrailingPadding))
        }
    }
    
    private enum InputFieldType: CaseIterable {
        case email, password
        
        var name: String {
            switch self {
            case .email : return "이메일"
            case .password : return "비밀번호"
            }
        }
        
        func bindingValue(with viewModel: ObservedObject<LoginViewModel>.Wrapper) -> Binding<String> {
            switch self {
            case .email : return viewModel.id
            case .password : return viewModel.password
            }
        }
        
        private var needSecurity: Bool {
            switch self {
            case .email : return false
            case .password : return true
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
    
    @ObservedObject private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: Constraint.zeroPadding) {
            self.logo
            self.inputField
            self.loginButton
            self.accountOptionButtons
            
            Spacer()
        }
    }
    
    private var logo: some View {
        Image(Constraint.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Constraint.imageWidth,
                   height: Constraint.imageHeight,
                   alignment: .center)
            .padding(EdgeInsets(top: Constraint.imageTopPadding,
                                leading: Constraint.zeroPadding,
                                bottom: Constraint.zeroPadding,
                                trailing: Constraint.zeroPadding))
    }
    
    private var inputField: some View {
        VStack(spacing: Constraint.zeroPadding) {
            ForEach(InputFieldType.allCases, id: \.hashValue) { field in
                field.fieldView(with: field.bindingValue(with: self.$viewModel))
                if (field != InputFieldType.allCases.last) {
                    Spacer()
                }
            }
        }
        .frame(height: Constraint.inputFieldHeight, alignment: .center)
        .padding(EdgeInsets(top: Constraint.inputFieldTopPadding,
                            leading: Constraint.zeroPadding,
                            bottom: Constraint.zeroPadding,
                            trailing: Constraint.zeroPadding))
    }
    
    private var loginButton: some View {
        AccountConfirmButton(fieldName: Constraint.buttonName, action: self.loginButtonDidTouched)
            .padding(EdgeInsets(top: Constraint.buttonTopPadding,
                                leading: Constraint.zeroPadding,
                                bottom: Constraint.zeroPadding,
                                trailing: Constraint.zeroPadding))
    }
    
    private var accountOptionButtons: some View {
        HStack(alignment: .center) {
            SmallTextButton(title: Constraint.findIdPwButtonName, action: self.findIdPwButtonDidTouched)
            Spacer()
            SmallTextButton(title: Constraint.signUpButtonName, action: self.signUpButtonDidTouched)
        }
        .frame(width: Constraint.accountOptionButtonsWidth, height: Constraint.accountOptionButtonsHeight)
        .padding(EdgeInsets(top: Constraint.accountOptionButtonsTopPadding,
                            leading: Constraint.zeroPadding,
                            bottom: Constraint.zeroPadding,
                            trailing: Constraint.zeroPadding))
    }
    
    // TODO: login 버튼 동작 구현 필요
    private func loginButtonDidTouched() {
        print("login \(self.viewModel.id) \(self.viewModel.password)")
    }
    
    // TODO: 아이디 비밀번호 찾기 버튼 동작 구현 필요
    private func findIdPwButtonDidTouched() {
        print("find Id/Pw button touched")
    }
    
    // TODO: 회원가입 버튼 동작 구현 필요
    private func signUpButtonDidTouched() {
        print("sign up button touched")
    }
    
}
