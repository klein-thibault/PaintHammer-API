//
//  UserToken.swift
//  
//
//  Created by Thibault Klein on 4/3/21.
//

import Vapor

final class UserToken: Content {
    var token: String

    init(token: String) {
        self.token = token
    }
}
