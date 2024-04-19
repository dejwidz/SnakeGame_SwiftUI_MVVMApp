//
//  Enum MovingDirection.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 19/03/2024.
//

import Foundation

enum MovingDirection {
    case up
    case down
    case left
    case right
    
    func nextField(currentField: (column: Int, row: Int)) -> (column: Int, row: Int) {
        var nextField = currentField
        switch self {
        case .up:
            nextField.row -= 1
        case .down:
            nextField.row += 1
        case .left:
            nextField.column -= 1
        case .right:
            nextField.column += 1
        }
        return nextField
    }
    
    func nextFieldIfIndexOutOfRange(currentField: (column: Int, row: Int)) -> (column: Int, row: Int) {
        var nextField = currentField
        switch self {
        case .up:
            nextField.row = 29
        case .down:
            nextField.row = 0
        case .left:
            nextField.column = 19
        case .right:
            nextField.column = 0
        }
        return nextField
    }
}
