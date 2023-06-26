//
//  SignupView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/03.
//

import SwiftUI

struct SignupView: View {
    
    private struct Constraint{
        static let zeroPadding: CGFloat = 0
        
        static let fields: [InputFieldType] = [.name, .email, .password, .passwordCheck]
        
        static let exitButtonLeadingPadding: CGFloat = 15
        static let alertButtonName: String = "확인"
        static let signupMessageTitle: String = "회원가입"
        static let signupSuccessMessage: String = "회원가입을 완료했습니다.\n로그인 페이지로 이동합니다."
        
        static let inputFieldTopPadding: CGFloat = 110
        static let inputFieldHeight: CGFloat = 300
        
        static let buttonName: String = "회원가입"
        static let buttonTopPadding: CGFloat = 34
        
        static let defaultErrorMessage: String = "회원가입 중 오류가 발생했습니다."
        static let signupMessageTopPadding: CGFloat = 5
    }
    
    @Binding private var doSignup: Bool
    @ObservedObject private var viewModel: SignupViewModel
    @FocusState private var focusedField: InputFieldType?
    
    init(doSignup: Binding<Bool>) {
        self._doSignup = doSignup
        self.viewModel = SignupViewModel()
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ExitButton(isShow: self.$doSignup)
                .padding(EdgeInsets(top: Constraint.zeroPadding,
                                    leading: Constraint.exitButtonLeadingPadding,
                                    bottom: Constraint.zeroPadding,
                                    trailing: Constraint.zeroPadding))
            VStack(alignment: .center, spacing: 0) {
                self.inputField
                ZStack(alignment: .top) {
                    if self.viewModel.didSignup == false && self.viewModel.signupMessage != nil {
                        self.signupMessage
                    }
                    self.signupButton
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .alert(Constraint.signupMessageTitle, isPresented: self.$viewModel.didSignup, actions: {
            Button(Constraint.alertButtonName) {
                self.doSignup = false
            }
        }, message: {
            Text(Constraint.signupSuccessMessage)
        })
        .alert(DCError.title, isPresented: self.$viewModel.didError, actions: {
            Button(Constraint.alertButtonName) {
                self.viewModel.didError = false
            }
        }, message: {
            Text(self.viewModel.error?.localizedDescription ?? DCError.unknown.message)
        })
    }
    
    private var inputField: some View {
        VStack(spacing: 0) {
            ForEach(Constraint.fields, id: \.hashValue) { field in
                field.fieldView(with: field.bindingValue(with: self.$viewModel))
                    .onSubmit {
                        self.focusedField = self.nextField(withCurrentField: field)
                    }
                    .focused(self.$focusedField, equals: field)
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
    
    private var signupMessage: some View {
        Text(self.viewModel.signupMessage ?? Constraint.defaultErrorMessage)
            .font(.AppleSDRegular12)
            .foregroundColor(.red)
            .frame(alignment: .center)
            .padding(EdgeInsets(top: Constraint.signupMessageTopPadding,
                                leading: Constraint.zeroPadding,
                                bottom: Constraint.zeroPadding,
                                trailing: Constraint.zeroPadding))
    }
    
    private var signupButton: some View {
        AccountConfirmButton(fieldName: Constraint.buttonName, action: self.signupButtonDidTouched)
            .padding(EdgeInsets(top: Constraint.buttonTopPadding,
                                leading: Constraint.zeroPadding,
                                bottom: Constraint.zeroPadding,
                                trailing: Constraint.zeroPadding))
    }
    
    private func signupButtonDidTouched() {
        self.viewModel.singup()
    }
    
    private func nextField(withCurrentField currentField: InputFieldType) -> InputFieldType? {
        switch currentField {
        case .name :
            return .email
        case .email :
            return .password
        case .password :
            return .passwordCheck
        case .passwordCheck :
            return nil
        }
    }
}

fileprivate extension InputFieldType {
    func bindingValue(with viewModel: ObservedObject<SignupViewModel>.Wrapper) -> Binding<String> {
        switch self {
        case .name : return viewModel.name
        case .email : return viewModel.email
        case .password : return viewModel.password
        case .passwordCheck : return viewModel.passwordCheck
        }
    }
}

