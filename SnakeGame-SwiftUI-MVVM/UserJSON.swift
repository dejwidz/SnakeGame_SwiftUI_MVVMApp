//
//  UserJSON.swift
//  SnakeGame-SwiftUI-MVVM
//
//  Created by Dawid Zimoch on 24/02/2024.
//

import Foundation

struct User: Decodable {
    
    struct Name: Decodable {
        let title: String
        let first: String
        let last: String
    }
    
    struct Picture: Decodable {
        let large: String
        let medium: String
        let thumbnail: String
    }
    
    let name: Name
    let picture: Picture
}

struct Results: Decodable {
    let results: [User]
    let info: Info
}

struct Info: Decodable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

class UserWithID: Identifiable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(pictureLink)
    }
    
    static func == (lhs: UserWithID, rhs: UserWithID) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
    
    var id = UUID()
    var firstName = ""
    var lastName = ""
    var pictureLink = ""
    var imageData: Data = Data()
    var score = 0
    
    init(id: UUID = UUID(), firstName: String = "", lastName: String = "", pictureLink: String = "", imageData: Data) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.pictureLink = pictureLink
        self.imageData = imageData
        getImageData()
        setScore()
    }
    
    func getImageData() {
        NetworkingServices.shared.getImage(link: pictureLink) { [weak self] result in
            switch result {
                
            case .success(let data):
                self?.imageData = data
            case .failure(let error):
                print("zadziała się niestety chujoza podczas pobierania danych do obrazka", error.localizedDescription)
            }
        }
    }
    
    private func setScore() {
        score = Int.random(in: 75...120)
    }
}
