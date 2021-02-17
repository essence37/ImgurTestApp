//
//  Comment.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 08.12.2020.
//

import Foundation

public struct Comment: Codable {
    public var id: Int
    public var comment: String
    // В стандартной возвращаемой модели нет этого параметра. Если комментарий содержит картинку, то ссылка на неё находится в тексте комментария. При парсинге ссылка перемещается в параметр image.
    public var image: URL?
    public var author: String
    
    public init(id: Int, comment: String, image: URL?, author: String) {
        self.id = id
        self.comment = comment
        self.image = image
        self.author = author
    }
}
