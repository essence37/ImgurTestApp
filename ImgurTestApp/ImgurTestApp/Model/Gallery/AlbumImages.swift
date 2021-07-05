//
//  AlbumImages.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 29.11.2020.
//

import Foundation

public struct AlbumImages: Codable {
    
    public var id: String
    public var link: String
    
    public init(id: String, link: String) {
        self.id = id
        self.link = link
    }
}
