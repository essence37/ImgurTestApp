//
//  RealmAlbumImages.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 15.02.2021.
//

import Foundation
import RealmSwift

class RealmAlbumImages: EmbeddedObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var link: String = ""
    
    convenience init(id: String, link: String) {
        self.init()
        self.id = id
        self.link = link
    }
}
