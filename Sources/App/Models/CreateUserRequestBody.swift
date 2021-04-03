//
//  CreateUserRequestBody.swift
//  
//
//  Created by Thibault Klein on 4/3/21.
//

import Vapor

struct CreateUserRequestBody: Content {
    var email: String
    var password: String
}
