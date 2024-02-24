//
//  SnakeOptions.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 24/02/2024.
//

import Foundation

class SnakeOptions: ObservableObject {
    
    @Published var snakeSpeed: TimeInterval = 1.5
    @Published var cutting = false
    @Published var lives: Int = 3
    @Published var bordersAllowed = false
    @Published var increasingSpeed = false
}
