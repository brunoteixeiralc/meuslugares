//
//  LocationDetailViewController.swift
//  meuslugares
//
//  Created by Bruno Lemgruber on 19/12/2017.
//  Copyright © 2017 Bruno Lemgruber. All rights reserved.
//

import UIKit
import CoreLocation

class LocationDetailViewController: UITableViewController {
    
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placeMark: CLPlacemark?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTxt.text = ""
        categoryLabel.text = ""
        latLabel.text = String(format: "%.8f",coordinate.latitude)
        longLabel.text = String(format: "%.8f",coordinate.longitude)
        
        if let placeMark = placeMark{
            addressLabel.text = string(from: placeMark)
        }else{
            addressLabel.text = "Não encontramos endereço."
        }
        
        dateLabel.text = format(date:Date())
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0{
            return 88
        }else if indexPath.section == 2 && indexPath.row == 2{
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 120, height: 1000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 16
            return addressLabel.frame.size.height + 20
        }else{
            return 44
        }
    }
    
    @IBAction func done(){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancel(){
        navigationController?.popViewController(animated: true)
    }
    
    func format(date:Date) -> String{
        return dateFormatter.string(from:date)
    }
    
    func string(from placemark: CLPlacemark) -> String{
        
        var line1 = ""
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare {
            line1 += s }
        
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s }
        
        return line1 + "\n" + line2
    }
}
