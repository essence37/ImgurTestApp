//
//  ErrorNetwork.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 08.12.2020.
//

import Foundation

enum ErrorNetwork: LocalizedError {
    case unreachableAddress(request: URLRequest)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unreachableAddress(let request): return "\(String(describing: request.url)) is unreachable"
        case .invalidResponse: return "Response with mistake"
        }
    }
}
