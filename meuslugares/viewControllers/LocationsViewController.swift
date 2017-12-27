//
//  LocationsViewController.swift
//  meuslugares
//
//  Created by Bruno Lemgruber on 27/12/2017.
//  Copyright © 2017 Bruno Lemgruber. All rights reserved.
//

import UIKit
import CoreData

class LocationsViewController: UITableViewController {

    var locations = [Location]()
    var managedObjectContext: NSManagedObjectContext?
    
    struct Storyboard {
        static let locationCell = "LocationCell"
        static let editLocation = "EditLocation"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLocations()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.locationCell,for:indexPath) as! LocationViewCell
        
        let location = locations[indexPath.row]
        cell.location = location
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Storyboard.editLocation{
            let controller = segue.destination as! LocationDetailViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                let location = locations[indexPath.row]
                controller.locationToEdit = location
            }
        }
    }
    
    func fetchLocations(){
     
        let fetchRequest = NSFetchRequest<Location>()
        let entity = Location.entity()
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do{
            locations = (try managedObjectContext?.fetch(fetchRequest))!
        }catch{
            fatalCoreDataError(error)
        }
    }
}
