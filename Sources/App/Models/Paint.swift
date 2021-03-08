//
//  Paint.swift
//  
//
//  Created by Thibault Klein on 3/4/21.
//

import Fluent
import Vapor

final class Paint: Model, Content {
    static let schema = "paints"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "brand")
    var brand: String

    @Field(key: "color")
    var color: String

    init() { }

    init(name: String, brand: String, color: String) {
        self.name = name
        self.brand = brand
        self.color = color
    }
}
