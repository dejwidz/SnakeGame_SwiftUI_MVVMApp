//
//  SnakeOptionsView.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 24/02/2024.
//

import Foundation
import SwiftUI

struct SnakeOptionsView: View {
    @EnvironmentObject private var snakeOptions: SnakeOptions
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Cutting is a snake ability to cut his tail where it comes to be too long. To activate it during the game, move 5 times up and right or left").textCase(.none)) {
                    Toggle(isOn: $snakeOptions.cutting) {
                        Text("Cutting")
                    }
                }
                Section(header: Text("If You dont want snake's food to be put in game borders, toggle this option off").textCase(.none)) {
                    Toggle(isOn: $snakeOptions.bordersAllowed) {
                        Text("Borders")
                    }
                }
                Section(header: Text("If You want increase snake's speed after every meal").textCase(.none)) {
                    Toggle(isOn: $snakeOptions.increasingSpeed) {
                        Text("Increasing speed")
                    }
                }
                Section(header: Text("Set snake speed")) {
                    Slider(value: $snakeOptions.snakeSpeed, in: 1...1.99)
                }
                Section(header: Text("Set lives")) {
                    Slider(value: Binding<Double>(
                        get: { Double(snakeOptions.lives) },
                        set: { snakeOptions.lives = Int($0) }
                    ), in: 1...10)
                }
                NavigationLink(destination: SnakeView(viewModel: SnakeViewModel())
                    .navigationTitle("Snake")
                    .navigationBarItems(
                        leading: Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Back")
                                .foregroundColor(.black)
                        })) {
                    Text("PLAY")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .navigationSplitViewColumnWidth(ideal: 50)
                }
            }
            .navigationBarTitle("Snake Options")
        }
    }
}

struct SnakeOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SnakeOptionsView()
            .environmentObject(SnakeOptions())
    }
}

