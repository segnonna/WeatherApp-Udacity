//
//  ErrorResponse.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 13/04/2022.
//

import Foundation

struct ErrorResponse: Codable {
    let code: Int
    let message: String
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
