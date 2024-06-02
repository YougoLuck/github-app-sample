//
//  Progress.swift
//  github-sample
//
//  Created by Yaohao Chen on 2024/06/02.
//

import Foundation
import SwiftUI

extension View {
    func progress(
        isPresented: Bool
    ) -> some View {
        modifier(
            CommonProgress(
                isPresented: isPresented
            )
        )
    }
}

struct CommonProgress: ViewModifier {
    var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .disabled(isPresented)
            .overlay {
                if isPresented {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding()
                        .tint(Color.white)
                        .background(Color.gray)
                        .cornerRadius(8)
                        .scaleEffect(1.2)
                }
            }
    }
}
