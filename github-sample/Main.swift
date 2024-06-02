//
//  github_sampleApp.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import SwiftUI

@main
struct MainView: App {
    var body: some Scene {
        WindowGroup {
            GithubUserListBuiler.build()
        }
    }
}
