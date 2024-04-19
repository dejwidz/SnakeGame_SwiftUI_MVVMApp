//
//  ContentView.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 24/02/2024.
//

import SwiftUI

struct SnakeView<ViewModel>: View where ViewModel: SnakeVM {
    
    @EnvironmentObject private var snakeOptions: SnakeOptions
    @ObservedObject private(set)var viewModel: ViewModel
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var showUsersView = false
    private var columnNumber: Int = 20
    private var rowNumber: Int = 30
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
            HStack {
                Spacer()
                ForEach(0..<(columnNumber),id: \.self) { col in
                    VStack {
                        ForEach(0..<(rowNumber), id: \.self) { row in
                            Rectangle().fill(viewModel.setColor(board: viewModel.board, column: col, row: row))
                        }
                        .padding(-3.0)
                        Spacer()
                    }
                }
                .alert(isPresented: $viewModel.gameOverIndicator) {
                    Alert(
                        title: Text("GAME OVER"),
                        message: Text("Nice Score"),
                        dismissButton: .default(Text("Hall of Fame"), action: {
                            showUsersView.toggle()
                        })
                    )
                }
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            
                            offsetX = gesture.translation.width
                            offsetY = gesture.translation.height

                            if offsetX > 0 && abs(offsetY) < abs(offsetX) {
                                viewModel.changeDirection(.right)
                            } else if offsetX < 0 && abs(offsetY) < abs(offsetX) {
                                viewModel.changeDirection(.left)
                            }

                            if offsetY > 0 && abs(offsetY) > abs(offsetX){
                                viewModel.changeDirection(.down)
                            } else if offsetY < 0 && abs(offsetY) > abs(offsetX){
                                viewModel.changeDirection(.up)
                            }
                        }
                        .onEnded { _ in
                            offsetX = 0
                            offsetY = 0
                        }
                )
                Spacer()
            }
            .background(Color.snakeColor)
            .onAppear {
                self.viewModel.setup(snakeOptions: snakeOptions)
            }
            .fullScreenCover(isPresented: $showUsersView) {
                UsersView(viewModel: UsersViewModel(model: NetworkingServices.shared))
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Score - \(viewModel.score) Lives - \(viewModel.lives)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SnakeView(viewModel: SnakeViewModel())
        .environmentObject(SnakeOptions())
    }
}
