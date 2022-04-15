//
//  FavoritesController.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 14/04/2022.
//

import Foundation
import UIKit
import GooglePlaces
import CoreData

class FavoritesController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var emptyList: UILabel!
    
    private var fetchedResultController: NSFetchedResultsController<Favorite>!
    
    var dataController:DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFetchedResultController()
        
        setUpViews(!(fetchedResultController?.fetchedObjects?.isEmpty ?? true))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultController = nil
    }
    
    @IBAction func addFavoritePlace(_ sender: Any) {
        autocompleteClicked(sender)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aFavorite = fetchedResultController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        cell.textLabel?.text = aFavorite.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let aFavorite = fetchedResultController.object(at: indexPath)
        let detailController = storyboard?.instantiateViewController(withIdentifier: "FavoriteDetailsController") as! FavoriteDetailsController
        detailController.latitude = aFavorite.latitude
        detailController.longitude = aFavorite.longitude
        present(detailController, animated: true)
    }
    
    func autocompleteClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        
        autocompleteController.delegate = self
        autocompleteController.placeFields = []
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.coordinate.rawValue))
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    private func setUpViews(_ showTable: Bool) {
        tableView.isHidden = !showTable
       emptyList.isHidden = showTable
    }
    
    fileprivate func setUpFetchedResultController() {
        let fetcherRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        let sortDescriptor =  NSSortDescriptor(key: "latitude", ascending: true)
        fetcherRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetcherRequest, managedObjectContext: dataController.viewContex, sectionNameKeyPath: nil, cacheName: "favorite")
        fetchedResultController.delegate = self
        
        do{
            try fetchedResultController.performFetch()
        }catch {
            fatalError("The fetch could not be perfomed: \(error.localizedDescription)")
        }
    }
    
}

extension FavoritesController {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        setUpViews(!(fetchedResultController?.fetchedObjects?.isEmpty ?? true))
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        default:
            break
        }
    }
    

    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let bgContext:NSManagedObjectContext! = self.dataController.backgroundContext
        debugPrint(place.name ?? "")
        debugPrint(place.coordinate.latitude)
        debugPrint(place.coordinate.longitude)
        bgContext?.perform {
            let favorite = Favorite(context: bgContext)
            favorite.name = place.name ?? ""
            favorite.latitude = place.coordinate.latitude
            favorite.longitude = place.coordinate.longitude
            try? bgContext.save()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
