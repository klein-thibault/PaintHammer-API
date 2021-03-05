//
//  Paint.swift
//  
//
//  Created by Thibault Klein on 3/4/21.
//

import Fluent
import Vapor

final class Paint: Content {
    var id = UUID()
    var name: String
    var brand: String
    var color: String

    init(name: String, brand: String, color: String) {
        self.name = name
        self.brand = brand
        self.color = color
    }
}
