//
//  FieldState.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 19/03/2024.
//

import Foundation

struct FieldState: Identifiable, Hashable {
    var id = UUID()
    var fieldState: CellState
}
