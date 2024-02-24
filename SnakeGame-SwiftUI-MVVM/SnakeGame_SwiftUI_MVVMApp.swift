//
//  SnakeGame_SwiftUI_MVVMApp.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 24/02/2024.
//

import SwiftUI



@main
struct SnakeGame_SwiftUI_MVVMApp: App {
    
    @StateObject var snakeOptions = SnakeOptions()

    var body: some Scene {
        WindowGroup {
            SceneFactory.makeContentScene()
                .environmentObject(snakeOptions)
        }
    }
}

enum SceneFactory {
    static func makeContentScene() -> some View {
        let view = SnakeOptionsView()
        return view
    }
}
