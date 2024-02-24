//
//  UsersViewModelProtocol.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 24/02/2024.
//

import Foundation
import Combine

protocol UsersViewModelProtocol: ObservableObject {
    var users: [UserWithID] { get set }
    func getUser()
}

final class UsersViewModel: UsersViewModelProtocol {
    
    @Published var users: [UserWithID] = []
    private var counter = 100
    private var user: User?
    private var auxiliaryUsersBoard: [UserWithID] = []
    private var model: UsersDataProvider
    
    init(model: UsersDataProvider) {
        self.model = model
    }
    
    func getUser() {
        model.getUserFromNet(completion: {[weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
                let newUser = UserWithID(firstName: user.name.first, lastName: user.name.last, pictureLink: user.picture.large, imageData: Data())
                self?.addUser(newUser: newUser)
            case .failure(let error):
                print("sa my w bledzie ", error.localizedDescription)
            }
        })
    }
    
    private func addUser(newUser: UserWithID) {
        guard checkUniqueness(url: newUser.pictureLink) else {
            getUser()
            return
        }
        auxiliaryUsersBoard.append(newUser)
        
        if counter > 0 {
            counter -= 1
            getUser()
        }
        if counter < 80 {
            auxiliaryUsersBoard.sort {$0.score > $1.score}
            users = auxiliaryUsersBoard
        }
    }
    
    private func checkUniqueness(url: String) -> Bool {
        var valueToReturn = true
        auxiliaryUsersBoard.forEach {
            if $0.pictureLink == url {
                valueToReturn = false
            }
        }
        return valueToReturn
    }
}
