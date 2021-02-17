//
//  APIClient.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 29.11.2020.
//

import Foundation
import Combine

struct APIClient {
    private let queue = DispatchQueue(label: "APIClient", qos: .default, attributes: .concurrent)
    
    func gallery(page: Int64) -> AnyPublisher<ParsingService.GalleryAPIResult, ErrorNetwork> {
        return URLSession.shared
            .dataTaskPublisher(for: Method.gallery(page).request)
            .receive(on: queue)
            .map(\.data)
            .tryMap({
                try ParsingService.GalleryAPIResult.init(apiData: $0)
            })
            .mapError({ error -> ErrorNetwork in
                switch error {
                case is URLError:
                    return ErrorNetwork.unreachableAddress(request: Method.gallery(page).request)
                default:
                    return ErrorNetwork.invalidResponse
                }
            })
            .eraseToAnyPublisher()
    }
    
    func imageComments(imageId: String) -> AnyPublisher<ParsingService.ImageCommentsAPIResult, ErrorNetwork> {
        return URLSession.shared
            .dataTaskPublisher(for: Method.imageComments(imageId).request)
            .receive(on: queue)
            .map(\.data)
            .tryMap({
                try ParsingService.ImageCommentsAPIResult.init(apiData: $0)
            })
            .mapError({ error -> ErrorNetwork in
                switch error {
                case is URLError:
                    return ErrorNetwork.unreachableAddress(request: Method.imageComments(imageId).request)
                default:
                    return ErrorNetwork.invalidResponse
                }
            })
            .eraseToAnyPublisher()
    }
}
