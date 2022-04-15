//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 13/04/2022.
//

import UIKit
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "Weather")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSPlacesClient.provideAPIKey("AIzaSyDYz_nl4MvkTK1Drp5MvFtytdCh6_xOPP4")
        dataController.load()
        
        let tabController = window?.rootViewController as! UITabBarController
        
        let currentWeatherController = tabController.viewControllers![0] as! CurrentWeatherViewController
        currentWeatherController.dataController = dataController
        
        let favoriteController = tabController.viewControllers![1] as! FavoritesController
        favoriteController.dataController = dataController
        
        tabController.selectedIndex = 0
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContex.save()
    }

}
