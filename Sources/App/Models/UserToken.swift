//
//  UserToken.swift
//  
//
//  Created by Thibault Klein on 4/3/21.
//

import Fluent
import Vapor

final class UserToken: Model, Content {
    static let schema = "tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(value: String, userId: User.IDValue) {
        self.value = value
        self.$user.id = userId
    }
}
