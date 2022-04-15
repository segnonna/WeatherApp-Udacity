//
//  WeatherApi.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 13/04/2022.
//

import Foundation

class WeatherApi {
    
    struct Constants {
        static let OPEN_WEATHER_API = "de101acfae21bbea418e3614631fcbeb"
    }
    enum Endpoints {
        
        static let BASE_URL = "https://api.openweathermap.org/data/2.5/"
        
    case currentWeather (String, Double, Double)
        
    case forecast (String, Double, Double)
        
        var stringValue: String {
            switch self {
            case .currentWeather(let appId, let latitude, let longitude): return "\(Endpoints.BASE_URL)weather?appid=\(appId)&lat=\(latitude)&lon=\(longitude)&units=metric"
                
            case .forecast(let appId, let latitude, let longitude): return "\(Endpoints.BASE_URL)onecall?appid=\(appId)&lat=\(latitude)&lon=\(longitude)&units=metric&cnt=5&excludecurrent,minutely,hourly,alerts,feels_like"
            
        }
    }
        var url: URL {
            return URL(string: stringValue)!
        }
}
    
    class func fetchCurrentWeather(latitude: Double, longitude: Double, completion: @escaping (CurrentWeatherResponse?, Error?) -> Void){
        debugPrint(Endpoints.currentWeather(Constants.OPEN_WEATHER_API,latitude, longitude).stringValue)
        taskForGETRequest(url: Endpoints.currentWeather(Constants.OPEN_WEATHER_API,latitude, longitude).url, responseType: CurrentWeatherResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func fetchForecast(_ latitude: Double, _ longitude: Double, completion: @escaping (ForecastResponse?, Error?) -> Void){
        taskForGETRequest(url: Endpoints.forecast(Constants.OPEN_WEATHER_API,latitude, longitude).url, responseType: ForecastResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    
    class private func taskForGETRequest<ResponseType: Decodable>(url: URL,responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                //print(String(data: data, encoding: .utf8)!)
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
}
