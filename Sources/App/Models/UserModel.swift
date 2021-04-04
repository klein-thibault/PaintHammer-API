//
//  UserModel.swift
//  
//
//  Created by Thibault Klein on 4/3/21.
//

import Fluent
import Vapor

final class UserModel: Model, Authenticatable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String

    init() { }

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
