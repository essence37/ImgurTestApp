//
//  Method.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 29.11.2020.
//

import Foundation

// Перечисление методов API.
enum Method {
    static let baseURL = URL(string: "https://api.imgur.com/3/")!
    
    case gallery(Int64)
    case imageComments(String)
    
    // Вычисляемое свойство, возвращающее полный URL для каждого метода.
    var request: URLRequest {
        switch self {
        case .gallery(let page):
            var request = URLRequest(url: Method.baseURL.appendingPathComponent("gallery/hot/viral/{{window}}/\(page)/?showViral={{showViral}}&mature={{showMature}}&album_previews={{albumPreviews}}"))
            request.addValue("Client-ID \(Session.instance.clientID)", forHTTPHeaderField: "Authorization")
            return request
        case .imageComments(let imageId):
            var request = URLRequest(url: Method.baseURL.appendingPathComponent("gallery/\(imageId)/comments/best"))
            request.addValue("Client-ID \(Session.instance.clientID)", forHTTPHeaderField: "Authorization")
            return request
        }
    }
}
