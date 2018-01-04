//
//  LocationViewCell.swift
//  meuslugares
//
//  Created by Bruno Lemgruber on 27/12/2017.
//  Copyright © 2017 Bruno Lemgruber. All rights reserved.
//

import UIKit

class LocationViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var location: Location! {
        
        didSet{
            if location.locationDescription.isEmpty{
                descriptionLabel.text = "(Sem descrição)"
            }else{
                descriptionLabel.text = location.locationDescription
            }
            
            if let placemark = location.placeMark {
                var text = ""
                text.add(text: placemark.subThoroughfare)
                text.add(text: placemark.thoroughfare, separatedBy: " ")
                text.add(text: placemark.locality, separatedBy: ", ")
                addressLabel.text = text
            } else {
                addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude,
                location.longitude)
            }
            
            photoImageView.image = thumbnail(for: location)
        }
    }
    
    func thumbnail(for location:Location) -> UIImage{
        if location.hasPhoto, let image = location.photoImage{
            return image.resized(withBounds: CGSize(width: 52, height: 52))
        }else{
            return UIImage()
        }
    }
}
