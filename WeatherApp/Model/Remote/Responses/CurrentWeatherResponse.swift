//
//  CurrentWeatherResponse.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 13/04/2022.
//

import Foundation

struct CurrentWeatherResponse: Codable {
    let weather: [Weather]?
    let main: Main?
    
    struct Main: Codable {
        let temp: Double?
        let feelsLike: Double?
        let tempMin: Double?
        let tempMax: Double?
        let pressure: Double?
        let humidity: Double?
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }

    struct Weather: Codable {
        let id: Int?
        let main: String?
    }
}



