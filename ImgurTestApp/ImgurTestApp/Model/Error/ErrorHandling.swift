//
//  Error.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 02.12.2020.
//

import Foundation

public struct ErrorHandling: Error, Codable {
    public var data: ErrorDescription
    public var success: Bool
    public var status: Int
    
    public init(data: ErrorDescription, success: Bool, status: Int) {
        self.data = data
        self.success = success
        self.status = status
    }
}
