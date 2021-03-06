//
//  LocationDetailViewController.swift
//  meuslugares
//
//  Created by Bruno Lemgruber on 19/12/2017.
//  Copyright © 2017 Bruno Lemgruber. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class LocationDetailViewController: UITableViewController {
    
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var image:UIImage?
    
    var categoryName = "Sem Categoria"
    var date = Date()
    var descriptionText = ""
    
    var managedObjectContext: NSManagedObjectContext?
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placeMark: CLPlacemark?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var locationToEdit: Location? {
        didSet{
            if let location = locationToEdit{
                title = "Editar localização"
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placeMark = location.placeMark
                
            }
        }
    }
    
    struct StoryBoard {
        static let pickerCategory = "PickerCategory"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = false

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenForBackgroundNotification()
        
        if let location = locationToEdit {
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    show(image: theImage)
                }
            }
        }
        
        descriptionTxt.text = ""
        categoryLabel.text = ""
        latLabel.text = String(format: "%.8f",coordinate.latitude)
        longLabel.text = String(format: "%.8f",coordinate.longitude)
        
        if let placeMark = placeMark{
            addressLabel.text = string(from: placeMark)
        }else{
            addressLabel.text = "Não encontramos endereço."
        }
        
        dateLabel.text = format(date:date)
        categoryLabel.text = categoryName
        descriptionTxt.text = descriptionText
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            return 88
        case (1,_):
            return imageView.isHidden ? 44 : 280
        case (2,2):
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 120, height: 1000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 16
            return addressLabel.frame.size.height + 20
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1{
            return indexPath
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0{
            descriptionTxt.becomeFirstResponder()
        }else if indexPath.section == 1 && indexPath.row == 0{
            tableView.deselectRow(at: indexPath, animated: true)
            showPhotoMenu()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoard.pickerCategory{
            let controller = segue.destination as! CategoryViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func done(){
        let hudView = HudView.hud(inView: (navigationController?.view)!, animated: true)
        
        let location:Location
        if let temp = locationToEdit{
            hudView.text = "Atualizado"
            location = temp
        }else{
          hudView.text = "Marcado"
          location = Location(context: managedObjectContext!)
          location.photoID = nil
        }
        
        location.locationDescription = descriptionTxt.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placeMark = nil
        
        if let image = image {
            if !location.hasPhoto{
                location.photoID = Location.nextPhotoID() as NSNumber
            }
        
            if let data = UIImageJPEGRepresentation(image, 0.5){
                do{
                    try data.write(to: location.photoURL,options: .atomic)
                }catch {
                    print("Erro: \(error)")
                }
            }
        }
        
        do {
            try managedObjectContext?.save()
            let delayInSeconds = 0.6
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
        }catch {
                hudView.hide()
                fatalCoreDataError(error)
            }
    }
    
    @IBAction func cancel(){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func categoryPickerDidPick(_ segue: UIStoryboardSegue){
        let controller = segue.source as! CategoryViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    func listenForBackgroundNotification(){
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { [weak self] _ in
            
            if let weakSelf = self{
                if weakSelf.presentationController != nil{
                    weakSelf.dismiss(animated: true, completion: nil)
                }
                weakSelf.descriptionTxt.resignFirstResponder()
            }
        }
    }
   
    func format(date:Date) -> String{
        return dateFormatter.string(from:date)
    }
    
    func string(from placemark: CLPlacemark) -> String{
        
        var line = ""
        line.add(text: placemark.subThoroughfare)
        line.add(text: placemark.thoroughfare, separatedBy: " ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea,separatedBy: ", ")
        line.add(text: placemark.postalCode, separatedBy: " ")
        line.add(text: placemark.country, separatedBy: ", ")
        
        return line
    }
    
    func show(image:UIImage){
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        
        addPhotoLabel.isHidden = true
        
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath?.row == 0{
            return
        }
        descriptionTxt.resignFirstResponder()
    }
}

extension LocationDetailViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func takePhoto(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhoto(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            takePhoto()
        }else{
            choosePhoto()
        }
    }
    
    func showPhotoMenu(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actCancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(actCancel)
        
        let actPhoto = UIAlertAction(title: "Tirar foto", style: .default, handler: { _ in
            self.takePhoto()
        })
        alert.addAction(actPhoto)
        
        let actLibrary = UIAlertAction(title: "Escolher na biblioteca", style: .default, handler: { _ in
            self.choosePhoto()
        })
        alert.addAction(actLibrary)
        
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if let theImage = image{
            show(image: theImage)
        }
        
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
