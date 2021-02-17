//
//  Image Comments.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 08.12.2020.
//

import Foundation

public struct ImageComments: Codable {
    
    public var data: [Comment]?
    
    public init(data: [Comment]?) {
        self.data = data
    }
}
