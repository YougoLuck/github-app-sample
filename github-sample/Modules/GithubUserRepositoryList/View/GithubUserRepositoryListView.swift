//
//  GithubUserRepositoryListView.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import SwiftUI
import Kingfisher

struct GithubUserRepositoryListView: View {
    @ObservedObject private var presenter: GithubUserRepositoryListPresenter
    
    init(presenter: GithubUserRepositoryListPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        VStack {
            ScrollView {
                GithubUserRepositoryListHeader(
                    iconUrl: presenter.userDetailEntity.avatarUrl,
                    fullName: presenter.userDetailEntity.name ?? "-",
                    userID: presenter.userDetailEntity.login,
                    followers: String(presenter.userDetailEntity.followers),
                    following: String(presenter.userDetailEntity.following)
                )
                Divider()
                
                LazyVStack(spacing: .zero) {
                    ForEach(presenter.repositoryEntities, id: \.self) { entity in
                        GithubUserRepositoryView(
                            repositoryName: entity.name,
                            description: entity.description ?? "-",
                            language: entity.language ?? "-",
                            star: String(entity.stargazersCount ?? .zero))
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
        }
        .onAppear {
            presenter.appear()
        }
        .refreshable {
            await presenter.refresh()
        }
        .progress(isPresented: presenter.isLoading)
    }
}

struct GithubUserRepositoryListHeader: View {
    let iconUrl: String
    let fullName: String
    let userID: String
    let followers: String
    let following: String
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                KFImage(URL(string: iconUrl))
                    .placeholder { Color.gray }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                VStack {
                    Text(fullName)
                        .font(.system(size: 22))
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    Text(userID)
                        .font(.system(size: 18))
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                }
            }
            
            Group {
                Text(followers + "人のフォロワー" )
                Text(following + "人をフォロ中")
            }
            .font(.system(size: 16))
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}

struct GithubUserRepositoryView: View {
    let repositoryName: String
    let description: String
    let language: String
    let star: String
    
    var body: some View {
        VStack {
            Text(repositoryName)
                .font(.system(size: 22))
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .padding(.bottom, 3)
            
            Text(description)
                .foregroundStyle(.gray)
                .font(.system(size: 18))
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .lineLimit(nil)
                .padding(.bottom, 10)
            
            HStack(spacing: 15) {
                Text("★: \(star)")
                Text("language: \(language)")
                Spacer()
            }
            .font(.system(size: 18))
            
            Divider()
                .background(.black)
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}

#Preview {
    GithubUserRepositoryListBuilder.build(
        entity: GithubSearchUserEntity(
            login: "Test", 
            avatarUrl: ""
        )
    )
}
