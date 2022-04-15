//
//  ForecastResponse.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 13/04/2022.
//

import Foundation

struct ForecastResponse: Codable {
    let daily: [Daily]?
    struct Weather: Codable {
        let id: Int?
    }

    struct Temp: Codable {
        let min: Double?
        let max: Double?
    }

    struct Daily: Codable {
        let dt: Int?
        let temp: Temp?
        let weather: [Weather]?
    }
}


