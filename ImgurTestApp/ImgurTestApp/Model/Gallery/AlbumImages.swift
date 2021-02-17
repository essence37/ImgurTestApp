//
//  AlbumImages.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 29.11.2020.
//

import Foundation
import RealmSwift

public class AlbumImages: Codable {
    
    @objc dynamic public var id: String
    @objc dynamic public var link: String
    
    public init(id: String, link: String) {
        self.id = id
        self.link = link
    }
}
