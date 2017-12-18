//
//  CurrentLocationViewController.swift
//  meuslugares
//
//  Created by Bruno Lemgruber on 18/12/2017.
//  Copyright © 2017 Bruno Lemgruber. All rights reserved.
//

import UIKit
import CoreLocation

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
            startLocationManager()
        }
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
        }
    }
    
    func stopLocationManager(){
        if updatingLocation{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func configureGetLocationBtn(){
        if updatingLocation{
            getLocationBtn.setTitle("Parar", for: .normal)
        }else{
            getLocationBtn.setTitle("Qual a minha localização.", for: .normal)
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
        
        if myLocation != nil && newLocation.timestamp.timeIntervalSinceNow < -5{
            return
        }
        
        if myLocation != nil && newLocation.horizontalAccuracy < 0{
            return
        }
        
        if myLocation == nil || myLocation!.horizontalAccuracy > newLocation.horizontalAccuracy{
            myLocation = newLocation
            lastLocationError = nil
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                stopLocationManager()
            }
            updateLabels()
        }
    }
}
