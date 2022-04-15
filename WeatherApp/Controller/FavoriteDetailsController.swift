//
//  FavoriteDetails.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 15/04/2022.
//

import Foundation
import UIKit

class FavoriteDetailsController: UIViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var activityIndicatorForecast: UIActivityIndicatorView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var minimumTemperature: UILabel!
    
    @IBOutlet var currentTemperature: UILabel!
    
    @IBOutlet var maximumTemperature: UILabel!
    
    @IBOutlet var temperatureHeader: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    private var dailyForecast:[ForecastResponse.Daily]!
    
    private var backgroundColor: UIColor!
    
    var latitude: Double!
    var longitude: Double!
    
    fileprivate func loadCurrentWeather() {
        WeatherApi.fetchCurrentWeather(latitude: latitude, longitude: longitude) { response, error in
            self.showCurrentWeatherLoaderOrData(false)
            guard error == nil else {
                self.weatherFailureCase()
                return
            }
            
            self.weatherSuccessCase(response, self.latitude, self.longitude)
            
        }
    }
    
    override func viewDidLoad() {
        showCurrentWeatherLoaderOrData(true)
        loadCurrentWeather()
    }
    
    private func showCurrentWeatherLoaderOrData(_ isLoading: Bool){
        scrollView.isHidden = isLoading
        activityIndicator.isHidden = !isLoading
        activityIndicatorForecast.isHidden = isLoading
        if isLoading {activityIndicator.startAnimating()} else {activityIndicator.stopAnimating()}
    }
    
    
    fileprivate func weatherSuccessCase(_ response: CurrentWeatherResponse?, _ lat: Double, _ lng:Double) {
        backgroundColor = colorByWeatherID(response?.weather?.first?.id ?? 800)
        updateViews(response?.weather?.first?.id ?? 800, response?.main?.tempMin ?? 0, response?.main?.tempMax ?? 0, response?.main?.temp ?? 0,
                    self.minimumTemperature,
                    self.currentTemperature,
                    self.maximumTemperature,
                    self.temperatureHeader,
                    self.imageView,
                    self.scrollView)
      
        self.loadForecast(lat,lng, colorByWeatherID(response?.weather?.first?.id ?? 800))
    }
    
    
    fileprivate func loadForecast(_ latitude: Double, _ longitude:Double, _ backGroundColor: UIColor) {
        showForeCastLoaderOrData(true)
        WeatherApi.fetchForecast(latitude, longitude) { responseForecast, error in
            
            self.dailyForecast = responseForecast?.daily?.suffix((responseForecast?.daily?.count ?? 0) - 1)
            self.tableView.backgroundColor = backGroundColor
            self.tableView.reloadData()
            self.showForeCastLoaderOrData(false)
        }
    }
    
    private func showForeCastLoaderOrData(_ isLoading: Bool){
        tableView.isHidden = isLoading
        activityIndicatorForecast.isHidden = !isLoading
        if isLoading {activityIndicatorForecast.startAnimating()} else {activityIndicatorForecast.stopAnimating()}
    }
    
    private func weatherFailureCase(){
        let alertVC = UIAlertController(title: "Weather app", message: "It seems you have issue with internet. Please fix it and retry.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [self](alert: UIAlertAction!) in
            loadCurrentWeather()
        }))
        alertVC.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

extension FavoriteDetailsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dailyForecast?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aDailyTem = self.dailyForecast?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell") as? ForecastTableViewCell
        
        cell?.temp.text = stringWithDegreeSymbol(String(aDailyTem?.temp?.max ?? 0.0))
        cell?.day.text = getDay(String(aDailyTem?.dt ?? 0))
        cell?.icon.image = iconeByWeatherID(aDailyTem?.weather?.first?.id ?? 800)
        cell?.backgroundColor = backgroundColor
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let detailController = storyboard?.instantiateViewController(withIdentifier: "ForecastTableViewCell") as! ForecastTableViewCell
        // detailController.memeImage = self.memes[indexPath.row].memedImage
        // navigationController?.pushViewController(detailController, animated: true)
    }
}
