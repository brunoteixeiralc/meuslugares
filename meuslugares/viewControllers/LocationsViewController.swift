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

    deinit {
        fetchedResultsController.delegate = nil
    }
    
    var managedObjectContext: NSManagedObjectContext?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        let fetchRequest = NSFetchRequest<Location>()
        
        let entity = Location.entity()
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1,sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "category", cacheName: "Locations")
        fetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        
        return fetchedResultsController
    }()
    
    struct Storyboard {
        static let locationCell = "LocationCell"
        static let editLocation = "EditLocation"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        performFetch()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.locationCell,for:indexPath) as! LocationViewCell
        
        let location = fetchedResultsController.object(at: indexPath)
        cell.location = location
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let location = fetchedResultsController.object(at: indexPath)
            location.removePhotoFile()
            managedObjectContext?.delete(location)
            do{
                try managedObjectContext?.save()
            }catch{
                fatalCoreDataError(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let labelRect = CGRect(x: 15,
                               y: tableView.sectionHeaderHeight - 14,
                               width: 300, height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = tableView.dataSource!.tableView!(
            tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(red: 241, green: 80, blue: 37)
        label.backgroundColor = UIColor.clear
        let separatorRect = CGRect(
            x: 15, y: tableView.sectionHeaderHeight - 0.5,
            width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        let viewRect = CGRect(x: 0, y: 0,
                              width: tableView.bounds.size.width,
                              height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor.white
        view.addSubview(label)
        view.addSubview(separator)
        return view
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Storyboard.editLocation{
            let controller = segue.destination as! LocationDetailViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                let location = fetchedResultsController.object(at: indexPath)
                controller.locationToEdit = location
            }
        }
    }
    
    func performFetch(){
        do{
            try fetchedResultsController.performFetch()
        }catch {
            fatalCoreDataError(error)
        }
    }
}

extension LocationsViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationViewCell{
                let location = controller.object(at: indexPath!) as! Location
                cell.location = location
            }
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer:sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer:sectionIndex), with: .fade)
        case .update:
            print("update")
        case .move:
            print("movendo")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
