//
//  UsersView.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 24/02/2024.
//

import SwiftUI

struct UsersView<ViewModel>: View where ViewModel: UsersViewModelProtocol {
    @ObservedObject private(set)var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    @State private var isLoading = true
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    private var rotationAngles: Angle = .degrees(0)
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.users.count < 20 {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .foregroundColor(Color.snakeHeadColor)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .onAppear {
                            viewModel.getUser()
                        }
                }
                else {
                    List {
                        ForEach(viewModel.users.indices, id: \.self) { index in
                            let item = viewModel.users[index]
                            HStack {
                                
                                if let uiImage = UIImage(data: item.imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .rotationEffect(rotationAngles)
                                        .overlay(Circle().stroke(
                                            Color.black, lineWidth: 5))
                                } else {
                                    Text("Błąd ładowania obrazu")
                                }
                                Spacer()
                                VStack {
                                    Text(item.firstName)
                                    Text(item.lastName)
                                }
                                Spacer()
                                VStack {
                                    Text("Score")
                                    Text("\(item.score)")
                                }
                            }
                            .listRowBackground(index % 2 == 0 ? Color.snakeColor : Color.fieldColor)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .background(Color.fieldColor)
            .navigationTitle(Text("Hall Of Fame"))
            .navigationBarItems(
                leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back")
                        .foregroundColor(.black)
                }
            )
        }
    }
}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView(viewModel: UsersViewModel(model: NetworkingServices.shared))
    }
}
