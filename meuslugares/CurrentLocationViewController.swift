//
//  CurrentLocationViewController.swift
//  meuslugares
//
//  Created by Bruno Lemgruber on 18/12/2017.
//  Copyright © 2017 Bruno Lemgruber. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagBtn: UIButton!
    @IBOutlet weak var getLocationBtn: UIButton!
    
    let locationManager = CLLocationManager()
    var myLocation: CLLocation?
    var updatingLocation = false
    var lastLocationError:Error?
    
    let geoCoder = CLGeocoder()
    var placeMark: CLPlacemark?
    var performingReverseGeoCoding = false
    var lastGeocodingError:Error?
    
    var timer: Timer?
    
    var managedObjectContext: NSManagedObjectContext?
    
    struct StoryBoard {
        static let tagLocation = "TagLocation"
    }
    
    @IBAction func getLocation(){
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted{
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation{
            stopLocationManager()
        }else{
            myLocation = nil
            lastLocationError = nil
            placeMark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Serviço de localização desabilitado.", message: "Por favor habilite o serviço de localização em Configurações no seu celular.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)

    }
    
    func updateLabels(){
        if let location = myLocation {
            latLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longLabel.text = String(format: "%.8f", location.coordinate.longitude)
            
            tagBtn.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placeMark{
                addressLabel.text = string(from:placemark)
            }else if performingReverseGeoCoding{
                addressLabel.text = "Procurando endereço..."
            }else if lastGeocodingError != nil{
                addressLabel.text = "Erro para achar endereço."
            }else{
                addressLabel.text = "Não encontramos endereço."
            }
            
        }else{
            latLabel.text = ""
            longLabel.text = ""
            addressLabel.text = ""
            tagBtn.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue{
                    statusMessage = "Serviço de localização desabilitado."
                }else{
                    statusMessage = "Erro ao pegar localização."
                }
            }else if !CLLocationManager.locationServicesEnabled(){
                statusMessage = "Serviço de localização desabilitado."
            }else if updatingLocation{
                statusMessage = "Procurando..."
            }else{
                statusMessage = "Clique 'Qual a minha localização' para começar."
            }
            
            messageLabel.text = statusMessage
        }
        
        configureGetLocationBtn()
    }
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager(){
        if updatingLocation{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer{
                timer.invalidate()
            }
        }
    }
    
    func configureGetLocationBtn(){
        if updatingLocation{
            getLocationBtn.setTitle("Parar", for: .normal)
        }else{
            getLocationBtn.setTitle("Qual a minha localização.", for: .normal)
        }
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
    
    @objc func didTimeOut(){
        print("Time Out")
        if myLocation == nil{
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoard.tagLocation{
            let controller = segue.destination as! LocationDetailViewController
            controller.coordinate = myLocation!.coordinate
            controller.placeMark = placeMark
            controller.managedObjectContext = managedObjectContext
        }
    }
}

extension CurrentLocationViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("falhou com erro: \(error)")
        
        if(error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("atualizou localização: \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5{
            return
        }
        
        if newLocation.horizontalAccuracy < 0{
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = myLocation{
            distance = newLocation.distance(from: location)
        }
        
        if myLocation == nil || myLocation!.horizontalAccuracy > newLocation.horizontalAccuracy{
            myLocation = newLocation
            lastLocationError = nil
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                stopLocationManager()
                
                if distance > 0 {
                    performingReverseGeoCoding = false
                }
            }
            
            if !performingReverseGeoCoding{
                performingReverseGeoCoding = true
                
                geoCoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) in
                   self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty{
                        self.placeMark = p.last!
                    }else{
                        self.placeMark = nil
                    }
                    
                    self.performingReverseGeoCoding = false
                    self.updateLabels()
                })
            }
            
        } else if distance < 1{
            let timeInterval = newLocation.timestamp.timeIntervalSince(myLocation!.timestamp)
            if timeInterval > 10 {
                stopLocationManager()
                updateLabels()
            }
        }
    }
}
