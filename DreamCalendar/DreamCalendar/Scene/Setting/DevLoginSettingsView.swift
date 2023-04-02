//
//  DevLoginSetting.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/03/23.
//

import SwiftUI

#if DEVELOP
struct DevLoginSettingsView: View {
    
    @State private var accessTokenTest: Bool = DeveloperConfiguration.global.loginSetting.accessTokenTest
    @State private var refreshTokenTest: Int = DeveloperConfiguration.global.loginSetting.refreshTokenTest
    
    var body: some View {
        NavigationView {
            List {
                self.developSection()
            }
        }
    }
    
    private func developSection() -> some View {
        let title = "개발자"
        let fields = ["AccessToken 1분 만료", "RefreshToken 만료 시간"]
        
        enum RefreshTokenTestMode: Int, CaseIterable {
            case basic = 0, refresh, expire
            
            var title: String {
                switch self {
                case .basic : return "기본"
                case .refresh : return "1분 뒤 새로고침"
                case .expire : return "1분 뒤 만료"
                }
            }
        }
        
        return Section(header: Text(title)) {
            Toggle(fields[0], isOn: self.$accessTokenTest)
                .onChange(of: self.accessTokenTest) { result in
                    DeveloperConfiguration.global.testAccessToken(isOn: result)
                }
            
            NavigationLink(fields[1]) {
                List {
                    ForEach(RefreshTokenTestMode.allCases, id: \.rawValue) { mode in
                        HStack {
                            Text(mode.title)
                            Spacer()
                            if self.refreshTokenTest == mode.rawValue {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.refreshTokenTest = mode.rawValue
                        }
                    }
                }
                .onChange(of: self.refreshTokenTest) { result in
                    DeveloperConfiguration.global.testRefreshToken(result)
                }
            }
        }
    }

}
#endif
