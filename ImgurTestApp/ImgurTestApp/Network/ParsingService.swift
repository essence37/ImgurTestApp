//
//  ParsingService.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 06.12.2020.
//

import Foundation

// Так как в результате одного запроса могут возвращаться разные модели данных, целесообразно вынести парсинг из Publisher.
enum ParsingService {
    typealias GalleryAPIResult = Result<Gallery, ErrorHandling>
    typealias ImageCommentsAPIResult = Result<[Comment], ErrorHandling>
}

extension ParsingService.GalleryAPIResult {
    init(apiData: Data) throws {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(Gallery.self, from: apiData)
            self = .success(response)
        } catch {
            let error = try decoder.decode(ErrorHandling.self, from: apiData)
            self = .failure(error)
        }
    }
}

extension ParsingService.ImageCommentsAPIResult {
    init(apiData: Data) throws {
        let decoder = JSONDecoder()
        // Возможные форматы изображения в тексте комментария.
        let supportedFormats = [".png", ".jpg", ".gif"]
        // Определитель ссылок.
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        do {
            let imageComments = try decoder.decode(ImageComments.self, from: apiData)
            let response = imageComments.data!.map({ (comment) -> Comment in
                let input = comment.comment
                // Если комментарий содержит метку одного из "читаемых" форматов изображений...
                if supportedFormats.contains(where: input.contains) {
                    // Совпадения (ссылки) в комментарии.
                    let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
                    for match in matches {
                        // Диапазон ссылки в общем комментарии.
                        guard let range = Range(match.range, in: input) else { continue }
                        // Ссылка.
                        let url = input[range]
                        // Удаление ссылки из текста комментария.
                        let newComment = input.replacingOccurrences(of: url, with: "")
                        return Comment(id: comment.id, comment: newComment, image: URL(string: String(url)), author: comment.author)
                    }
                }
                return comment
            })
            self = .success(response)
        } catch {
            let error = try decoder.decode(ErrorHandling.self, from: apiData)
            self = .failure(error)
        }
    }
}
