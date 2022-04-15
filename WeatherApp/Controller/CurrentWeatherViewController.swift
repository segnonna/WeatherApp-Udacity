//
//  ViewController.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 13/04/2022.
//

import UIKit
import CoreLocation
import CoreData

class CurrentWeatherViewController: UIViewController, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    private var locationManager:CLLocationManager!
    
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
    
    private var fetchedCurrentWeatherResultController: NSFetchedResultsController<CurrentWeather>!
    
    private var fetchedForecastResultController: NSFetchedResultsController<Forecast>!
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFetchedCurrentWeatherResultController()
        setUpFetchedForecastResultController()
        getUserCurrentLocation()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let userLocation :CLLocation = locations[0] as CLLocation
        
        debugPrint("user latitude = \(userLocation.coordinate.latitude)")
        debugPrint("user longitude = \(userLocation.coordinate.longitude)")
        
        
        WeatherApi.fetchCurrentWeather(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude) { response, error in
            
            self.showCurrentWeatherLoaderOrData(false)
            
            guard error == nil else {
                self.weatherFailureCase()
                return
            }
            
            self.weatherSuccessCase(response, userLocation.coordinate.latitude, userLocation.coordinate.longitude)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Error \(error)")
    }
    
    fileprivate func weatherFailureCase() {
        debugPrint("weatherFailureCase \(String(describing: fetchedCurrentWeatherResultController.fetchedObjects?.count))")
        activityIndicatorForecast.isHidden = true
        let currentWeather = fetchedCurrentWeatherResultController.fetchedObjects?.first
        updateViews(Int(currentWeather?.weatherId ?? 800 ), currentWeather?.min ?? 0, currentWeather?.max ?? 0, currentWeather?.current ?? 0,
                    self.minimumTemperature,
                    self.currentTemperature,
                    self.maximumTemperature,
                    self.temperatureHeader,
                    self.imageView,
                    self.scrollView)
        
        debugPrint("forecast \(String(describing: fetchedForecastResultController.fetchedObjects?.count))")
        
        dailyForecast = []
        let size = (fetchedForecastResultController.fetchedObjects?.count ?? 0) - 1
        if size > 0 {
            scrollView.isHidden = false
            fetchedForecastResultController.fetchedObjects?.suffix(size).forEach({ forecast in
                dailyForecast?.append(
                    ForecastResponse.Daily(dt: Int(forecast.timestamp),
                                           temp: ForecastResponse.Temp(min: forecast.max, max: forecast.max),
                                           weather: [ForecastResponse.Weather(id: Int(forecast.weatherId))])
                )
            })
            tableView.backgroundColor = backgroundColor
            tableView.delegate = self
            tableView.dataSource = self
            self.tableView.reloadData()
            self.showToast(message: "You are offline. This data may be outdated", font: .systemFont(ofSize: 12.0))
        } else {
            scrollView.isHidden = true
            showAlert()
        }
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
        self.removeCurrentWeatherFromLocal {
            self.addCurrentLocationToLocal(response?.weather?.first?.id ?? 800, response?.main?.tempMin ?? 0, response?.main?.tempMax ?? 0 , response?.main?.temp ?? 0)
        }
        self.loadForecast(lat,lng,colorByWeatherID(response?.weather?.first?.id ?? 800))
    }
    
    
    fileprivate func loadForecast(_ latitude: Double, _ longitude:Double, _ backGroundColor: UIColor) {
        self.showForeCastLoaderOrData(true)
        WeatherApi.fetchForecast(latitude, longitude) { responseForecast, error in
            
            self.removeForcastFromLocal {
                responseForecast?.daily?.forEach({ daily in
                    self.addForecastToLocal(daily.weather?.first?.id ?? 800, daily.temp?.max ?? 0, daily.dt ?? 0)
                })
            }
            
            self.dailyForecast = responseForecast?.daily?.suffix((responseForecast?.daily?.count ?? 0) - 1)
            self.tableView.backgroundColor = backGroundColor
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
            self.showForeCastLoaderOrData(false)
        }
    }
    
    private func showCurrentWeatherLoaderOrData(_ isLoading: Bool){
        scrollView.isHidden = isLoading
        activityIndicator.isHidden = !isLoading
        activityIndicatorForecast.isHidden = isLoading
        if isLoading {activityIndicator.startAnimating()} else {activityIndicator.stopAnimating()}
    }
    
    
    private func showForeCastLoaderOrData(_ isLoading: Bool){
        tableView.isHidden = isLoading
        activityIndicatorForecast.isHidden = !isLoading
        if isLoading {activityIndicatorForecast.startAnimating()} else {activityIndicatorForecast.stopAnimating()}
    }
    
    
    fileprivate func removeCurrentWeatherFromLocal(completion: @escaping () -> Void) {
        debugPrint("removeCurrentWeather")
        for currentWeather in fetchedCurrentWeatherResultController.fetchedObjects! {
            dataController.viewContex.delete(currentWeather)
            do {
                try dataController.viewContex.save()
            } catch {
                print(error)
            }
        }
        completion()
    }
    
    fileprivate func addCurrentLocationToLocal(_ weatherID: Int, _ min: Double, _ max: Double, _ current: Double) {
        
        dataController.backgroundContext.perform {
            let currentWeather = CurrentWeather(context: self.dataController.backgroundContext)
            currentWeather.weatherId = Int16(weatherID)
            currentWeather.min = min
            currentWeather.max = max
            currentWeather.current = current
            try? self.dataController.backgroundContext.save()
            
            debugPrint("addCurrentLocationToLocal \(String(describing: self.fetchedCurrentWeatherResultController.fetchedObjects?.count))")
        }
    }
    
    fileprivate func removeForcastFromLocal(completion: @escaping () -> Void) {
        for forecast in fetchedForecastResultController.fetchedObjects! {
            dataController.viewContex.delete(forecast)
            do {
                try dataController.viewContex.save()
            } catch {
                print(error)
            }
        }
        completion()
    }
    
    
    fileprivate func addForecastToLocal(_ weatherID: Int, _ max: Double, _ timestamp: Int) {
        debugPrint("addForecastToLocal")
        dataController.backgroundContext.perform {
            let forecast = Forecast(context: self.dataController.backgroundContext)
            forecast.weatherId = Int16(weatherID)
            forecast.max = max
            forecast.timestamp = Int32(timestamp)
            try? self.dataController.backgroundContext.save()
        }
    }
    
    fileprivate func setUpFetchedCurrentWeatherResultController() {
        let fetcherRequest: NSFetchRequest<CurrentWeather> = CurrentWeather.fetchRequest()
        let sortDescriptor =  NSSortDescriptor(key: "min", ascending: true)
        fetcherRequest.sortDescriptors = [sortDescriptor]
        
        fetchedCurrentWeatherResultController = NSFetchedResultsController(fetchRequest: fetcherRequest, managedObjectContext: dataController.viewContex, sectionNameKeyPath: nil, cacheName: "currentweather")
        fetchedCurrentWeatherResultController.delegate = self
        
        do{
            try fetchedCurrentWeatherResultController.performFetch()
        }catch {
            fatalError("The fetch could not be perfomed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func setUpFetchedForecastResultController() {
        let fetcherRequest: NSFetchRequest<Forecast> = Forecast.fetchRequest()
        let sortDescriptor =  NSSortDescriptor(key: "max", ascending: true)
        fetcherRequest.sortDescriptors = [sortDescriptor]
        
        fetchedForecastResultController = NSFetchedResultsController(fetchRequest: fetcherRequest, managedObjectContext: dataController.viewContex, sectionNameKeyPath: nil, cacheName: "forecast")
        fetchedForecastResultController.delegate = self
        
        do{
            try fetchedForecastResultController.performFetch()
        }catch {
            fatalError("The fetch could not be perfomed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func showAlert() {
        let alertVC = UIAlertController(title: "Weather app", message: "It seems you have issue with internet. Please fix it and retry.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [self](alert: UIAlertAction!) in
            getUserCurrentLocation()
        }))
        alertVC.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    fileprivate func getUserCurrentLocation() {
        showCurrentWeatherLoaderOrData(true)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
}

extension CurrentWeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
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

