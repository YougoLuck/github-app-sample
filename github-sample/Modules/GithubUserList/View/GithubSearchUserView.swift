//
//  GithubSearchUserView.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import SwiftUI
import Kingfisher

struct GithubSearchUserView: View {
    @ObservedObject private var presenter: GithubUserListPresenter
    
    init(presenter: GithubUserListPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        NavigationStack {
            GithubSearchUserHeader(
                searchInput: $presenter.searchInput,
                searchAction: { presenter.search() }
            )
            .navigationTitle("Github")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            
            if presenter.shouldShowList {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(
                            presenter.userEntities,
                            id: \.self
                        ) { entity in
                            NavigationLink(value: entity) {
                                GithubSearchUserListView(
                                    name: entity.login,
                                    iconUrl: entity.avatarUrl
                                )
                            }

                        }
                        .navigationDestination(for: GithubSearchUserEntity.self) { entity in
                            presenter.router.toUserRepositoryList(entity: entity)
                        }
                        
                        if presenter.canLoadMore {
                            Text("Loading ...")
                                .padding()
                                .onAppear {
                                    presenter.loadMore()
                                }
                        }
                    }
                }
            } else {
                Spacer()
            }
        }
        .progress(isPresented: presenter.isLoading)
    }
        
}

struct GithubSearchUserListView: View {
    let name: String
    let iconUrl: String
    
    var body: some View {
        VStack {
            HStack {
                KFImage(URL(string: iconUrl))
                    .placeholder { Color.gray }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    
                
                Spacer()
                    .frame(width: 20)
                
                Text(name)
                    .lineLimit(1)
                    .foregroundStyle(.black)
                
                Spacer()
            }
            
            Divider()
        }
        .buttonStyle(PlainButtonStyle())
        .padding(EdgeInsets(top: .zero, leading: 10, bottom: .zero, trailing: 10))
    }
}

struct GithubSearchUserHeader: View {
    @Binding var searchInput: String
    let searchAction: () -> ()
    
    var body: some View {
        VStack(spacing: 10) {
            Text("ユーザー検索")
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .font(.system(size: 20))
            
            HStack {
                TextField(
                    "ユーザー名を入力してください",
                    text: $searchInput
                )
                .autocorrectionDisabled()
                
                Button {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                    )
                    searchAction()
                } label: {
                    Text("検索")
                }
                .frame(width: 50)
            }
            
            Divider()
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
    }
}

#Preview {
    GithubUserListBuiler.build()
}
