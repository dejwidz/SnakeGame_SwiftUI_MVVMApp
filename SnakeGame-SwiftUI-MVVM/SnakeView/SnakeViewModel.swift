//
//  SnakeBoard.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 24/02/2024.
//

import Foundation

import Foundation
import SwiftUI
import Combine

protocol SnakeVM: ObservableObject {
    var board: [[FieldState]]? { get }
    var gameOverIndicator: Bool {get set}
    var lives: Int {get}
    var score: Int {get}
    func setup(snakeOptions: SnakeOptions)
    func changeDirection(_ newDirection: MovingDirection)
    func setColor(board: [[FieldState]]?, column: Int, row: Int) -> Color
}

class SnakeViewModel: SnakeVM {
    
    @Published var board: [[FieldState]]?
    @Published var gameOverIndicator = false {
        didSet {
            stopTimer()
        }
    }
    @Published var lives = 1 {
        didSet {
            if lives == 0 {
                gameOverIndicator = true
            }
        }
    }
    @Published var score: Int = 0
    private var actualFoodPosition: SnakeIndex = (column: 10, row: 10)
    private var snakeBody: [SnakeIndex] = []
    private var auxiliaryBoard: [[FieldState]]?
    private var snakeMovingDirection = MovingDirection.down
    private var snakeHeadPosition: SnakeIndex?
    private var snakeOptions: SnakeOptions?
    private var cutting = false
    private var speed: Double = 1
    private var cuttingArray: [MovingDirection] = []
    private var borders = true
    private var increasingSpeed = true
    private var timer: Timer?
    private var interval: TimeInterval = 1
    private var cuttingAbility = false
    typealias Completion = () -> ()
    typealias SnakeIndex = (column: Int, row: Int)
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            self.moveOn(direction: self.snakeMovingDirection, _snakeBody: self.snakeBody)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func setup(snakeOptions: SnakeOptions) {
        self.snakeOptions = snakeOptions
        self.cutting = snakeOptions.cutting
        self.interval = calculateSpeed()
        self.lives = snakeOptions.lives
        self.borders = snakeOptions.bordersAllowed
        self.increasingSpeed = snakeOptions.increasingSpeed
        self.board = makeBoard()
        self.auxiliaryBoard = makeBoard()
        
        initializeSnake()
        startTimer()
    }
    
    func setColor(board: [[FieldState]]?, column: Int, row: Int) -> Color {
        guard let state = board?[column][row].fieldState else {
            return .black
        }
        
        var colorToReturn = Color.orange
        
        switch state {
        case .free:
            colorToReturn = .fieldColor
        case .food:
            colorToReturn = .foodColor
        case .snakeBody:
            colorToReturn = .snakeColor
        case .snakeHead:
            colorToReturn = .snakeHeadColor
        case .cut:
            colorToReturn = .red
        }
        return colorToReturn
    }
    
    func changeDirection(_ newDirection: MovingDirection) {
        guard newDirection != snakeMovingDirection, checkNewDirection(newDirection: newDirection) else {
            return
        }
        snakeMovingDirection = newDirection
        cuttingRecognizer(newDirection: newDirection)
    }
    
    private func calculateSpeed() -> TimeInterval {
        return TimeInterval(2 - (snakeOptions?.snakeSpeed ?? 1))
    }
    
    private func increaseSpeed() {
        guard increasingSpeed else {return}
        guard interval > 0.01 else {return}
        interval -= 0.01
    }
    
    private func makeBoard() -> [[FieldState]] {
        var newBoard: [[FieldState]] = []
        for _ in 0...19 {
            var tempArray: [FieldState] = []
            for _ in 0...29 {
                let x = FieldState(fieldState: .free)
                tempArray.append(x)
            }
            newBoard.append(tempArray)
        }
        return newBoard
    }
    
    private func generateFood() {
        score += 1
        var column = 0
        var row = 0
        
        if borders {
            column = Int.random(in: 0...19)
            row = Int.random(in: 0...29)
        } else {
            column = Int.random(in: 1...18)
            row = Int.random(in: 1...28)
        }
        
        guard board?[column][row].fieldState == .free else {
            generateFood()
            return
        }
        
        actualFoodPosition.column = column
        actualFoodPosition.row = row
    }
    
    private func initializeSnake() {
        snakeBody = [
            (3,3),
            (3,2),
            (3,1),
            (3,0)
        ]
        putSnakeOnBoard(snakeBody: snakeBody)
    }
    
    private func putSnakeOnBoard(snakeBody: [SnakeIndex]) {
        guard var auxiliaryBoard = auxiliaryBoard else {return}
        for field in snakeBody {
            auxiliaryBoard[field.column][field.row].fieldState = .snakeBody
        }
        guard let field = snakeBody.first else {return}
        auxiliaryBoard[field.column][field.row].fieldState = .snakeHead
        auxiliaryBoard[actualFoodPosition.column][actualFoodPosition.row].fieldState = .food
        guard cuttingAbility else {
            board = auxiliaryBoard
            return
        }
        prepareSnakeToCut(snakeBody: snakeBody, board: &auxiliaryBoard)
        board = auxiliaryBoard
    }
    
    private func prepareSnakeToCut(snakeBody: [SnakeIndex], board: inout [[FieldState]]) {
        guard cuttingAbility else {return}
        let half = Int(snakeBody.count / 2)
        let lastHalf = Array(snakeBody.suffix(half))
        for field in lastHalf {
            board[field.column][field.row].fieldState = .cut
        }
    }
    
    private func saveAccess(field: SnakeIndex) -> Bool {
        var valueToReturn = true
        if field.column < 0 ||
            field.column > 19 ||
            field.row < 0 ||
            field.row > 29
        {
            valueToReturn = false
            
        }
        return valueToReturn
    }
    
    private func checkNextFieldStatus(nextField: SnakeIndex) -> Bool {
        let nextFieldStatus = board?[nextField.column][nextField.row].fieldState
        var valueToReturn = true
        switch nextFieldStatus {
        case .food:
            valueToReturn = true
        case .free:
            valueToReturn = true
        case.cut:
            valueToReturn = true
            snakeBody = cutSnake(index: nextField, snakesBody: snakeBody)
        case .snakeBody:
            guard lives > 0 else {
                valueToReturn = false
                return valueToReturn
            }
            lives -= 1
            valueToReturn = true
        case .snakeHead:
            valueToReturn = false
        case .none:
            valueToReturn = false
        }
        return valueToReturn
    }
    
    private func moveOn(direction: MovingDirection, _snakeBody: [SnakeIndex]) {
        guard !gameOverIndicator else {return}
        guard let currentHeadPosition = snakeBody.first else { return }
        var nextField = direction.nextField(currentField: currentHeadPosition)
        if saveAccess(field: nextField) {
            guard checkNextFieldStatus(nextField: nextField) else {
                gameOverIndicator = true
                return
            }
            moveAfterCheck(nextField: nextField)
        } else {
            lives -= 1
            if lives == 0 {
                gameOverIndicator = true
            }
            nextField = direction.nextFieldIfIndexOutOfRange(currentField: currentHeadPosition)
            moveAfterCheck(nextField: nextField)
        }
    }
    
    private func moveAfterCheck(nextField: SnakeIndex) {
        snakeBody.insert(nextField, at: 0)
        guard board?[nextField.column][nextField.row].fieldState == .food else {
            snakeBody.removeLast()
            putSnakeOnBoard(snakeBody: snakeBody)
            return
        }
        putSnakeOnBoard(snakeBody: snakeBody)
        generateFood()
        stopTimer()
        increaseSpeed()
        startTimer()
    }
    
    
    private func cutSnake(index: SnakeIndex, snakesBody: [SnakeIndex]) -> [SnakeIndex] {
        var counter = 0
        var newBody: [SnakeIndex] = []
        for field in snakeBody {
            if field == index {
                break
            }
            newBody.append(field)
            counter += 1
        }
        cuttingAbility = false
        return newBody
    }
    
    private func checkNewDirection(newDirection: MovingDirection) -> Bool {
        var valueToReturn = false
        switch snakeMovingDirection {
        case .down:
            if newDirection != .up {valueToReturn = true}
        case .up:
            if newDirection != .down {valueToReturn = true}
        case .left:
            if newDirection != .right {valueToReturn = true}
        case .right:
            if newDirection != .left {valueToReturn = true}
        }
        return valueToReturn
    }
    
    private func cuttingRecognizer(newDirection: MovingDirection) {
        guard cutting else {return}
        guard cuttingArray.count > 10 else {
            cuttingArray.insert(newDirection, at: 0)
            return
        }
        checkCuttingAbility(repeats: 10, currentPositionInCuttingArray: 0)
        cuttingArray.insert(newDirection, at: 0)
        guard cuttingArray.count > 10 else {
            return
        }
        cuttingArray.removeLast()
    }
    
    private func checkCuttingAbility(repeats: Int, currentPositionInCuttingArray: Int) {
        var up = 0
        cuttingArray.forEach { move in
            if move == .up {
                up += 1
            }
            
            if up == 5 {
                up = 0
                cuttingArray = []
                cuttingAbility = true
                countToCancelCutting {
                    self.cancelCutting()
                }
            }
        }
    }
    
    private func cancelCutting() {
        cuttingAbility = false
    }
    
    private func countToCancelCutting(handler: @escaping Completion) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            handler()
        }
    }
    
}
