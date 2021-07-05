//
//  ErrorDescription.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 02.12.2020.
//

import Foundation

public struct ErrorDescription: Error, Codable {
    public var error: String
    public var request: String
    public var method: String
    
    public init(error: String, request: String, method: String) {
        self.error = error
        self.request = request
        self.method = method
    }
}
