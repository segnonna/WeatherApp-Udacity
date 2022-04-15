//
//  ViewController+Extensions.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 13/04/2022.
//

import Foundation
import UIKit


func imageByWeatherID(_ id: Int) -> UIImage {
    switch id {
    case let id_ where String(id_).starts(with: "80") : return UIImage(named: "forest_cloudy")!
    case let id_ where String(id_).starts(with: "5") : return UIImage(named: "forest_rainy")!
    default:
        return UIImage(named: "forest_sunny")!
    }
}

func hexStringToUIColor ( _ hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}


func getDay(_ ts: String) -> String {
    let date = NSDate(timeIntervalSince1970: Double(ts)!)
    
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = "EEEE"
    
    return dayTimePeriodFormatter.string(from: date as Date)
}

func iconeByWeatherID(_ id: Int) -> UIImage {
    switch id {
    case let id_ where String(id_).starts(with: "80") : return UIImage(named: "clear")!
    case let id_ where String(id_).starts(with: "5") : return UIImage(named: "rain")!
    default:
        return UIImage(named: "partlysunny")!
    }
}

func stringWithDegreeSymbol(_ value: String) -> String{
    return value + "°"
}

func colorByWeatherID(_ id: Int) -> UIColor {
    switch id {
    case let id_ where String(id_).starts(with: "80") : return hexStringToUIColor("#54717A")
    case let id_ where String(id_).starts(with: "5") : return hexStringToUIColor("#57575D")
    default:
        return hexStringToUIColor("#47AB2F")
    }
}


func updateViews(_ weatherId: Int,
                 _ min: Double,
                 _ max: Double,
                 _ current: Double,
                 _ minimumTemperature: UILabel,
                 _ currentTemperature: UILabel,
                 _ maximumTemperature: UILabel,
                 _ temperatureHeader: UILabel,
                 _ imageView: UIImageView,
                 _ scrollView: UIScrollView){
    minimumTemperature.text =  stringWithDegreeSymbol("Min: "  + String(describing: min))
    
    currentTemperature.text =  stringWithDegreeSymbol("Current: " + String(describing: current))
    
    temperatureHeader.text =  stringWithDegreeSymbol( String(describing: current))
    
    maximumTemperature.text =  stringWithDegreeSymbol("Max: " + String(describing: max))
    
    imageView.image = imageByWeatherID(weatherId)
    scrollView.backgroundColor = colorByWeatherID(weatherId)
}
