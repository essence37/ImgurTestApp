//
//  Gallery.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 02.12.2020.
//

import Foundation

public struct Gallery: Codable {
    
    public var data: [GalleryAlbum]
    
    public init(data: [GalleryAlbum]) {
        self.data = data
    }
}
