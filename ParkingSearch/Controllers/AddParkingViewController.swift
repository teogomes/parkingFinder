//
//  AddParkingViewController.swift
//  ParkingSearch
//
//  Created by Teodoro Gomes on 07/06/2018.
//  Copyright © 2018 Teodoro Gomes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class AddParkingViewController: UIViewController,CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate{
    
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var endPicker: UIDatePicker!
    @IBOutlet weak var startPicker: UIDatePicker!
    var valueSelected:String="1"
    let price = ["1","2","3"]
    var startDate:String = ""
    var endDate:String = ""
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return price.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return price[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        valueSelected = price[row] as String
       
    }
    
    var ref:DatabaseReference!
    @IBOutlet weak var uploadedImage: UIImageView!
    @IBOutlet weak var locationTextBox: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        locationTextBox.delegate = self
        ref = Database.database().reference()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
      
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButton(_ sender: Any) {
        
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = locationTextBox.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            if response == nil {
                print("ERROR")
                self.createAlert(title: "Error", message: "Please Select A location and a valid Date to sumbit the parking")
            }else {
                //Getting Data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                let latitudeText:String = "\(latitude ?? 0)"
                let longitudeText:String = "\(longitude ?? 0)"
                self.uploadImage(lati: latitudeText, long: longitudeText , url: "test",price: self.valueSelected)
                self.createAlert(title: "Thank you", message: "Parking has succesfully submitted")
            }
        }
        
        
    }
    
  
    @IBAction func photoPickers(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        print("Cancelled")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImageFromPicker:UIImage?
        if let originalmage = info[UIImagePickerControllerOriginalImage] as? UIImage{
             selectedImageFromPicker = originalmage
             uploadedImage.image = selectedImageFromPicker
          
        }
      dismiss(animated: true, completion: nil)
        
    }
    
    func uploadImage(lati:String , long:String ,url:String,price:String){
        var downloadUrl:String = "none"
        let storage = Storage.storage()
        var data = Data()
        if(uploadedImage.image != nil){
            data = UIImagePNGRepresentation(uploadedImage.image!)! // image file name
            // Create a storage reference from our storage service
            let storageRef = storage.reference()
            let imageRef = storageRef.child("parkingImages/\(lati)\(long).png")
            _ = imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
                if error != nil {
                    print(error!)
                    return
                }else{
                    imageRef.downloadURL(completion: { (url, error) in
                        downloadUrl = (url?.absoluteString)!
                        let formatter = DateFormatter()
                        //MUST CHANGE THE TYPE OF DATE IN DB
                         formatter.dateFormat = "dd.MM.yyyy hh:mm a"
                        self.addParking(lati: lati, long: long, url: downloadUrl, price: price,startDate:  formatter.string(from: self.startPicker.date),endDate: formatter.string(from:self.endPicker.date))
                    })
                }
            })

        }else{
            let formatter = DateFormatter()
            //MUST CHANGE THE TYPE OF DATE IN DB
            formatter.dateFormat = "dd.MM.yyyy hh:mm a"
              self.addParking(lati: lati, long: long, url: downloadUrl, price: price,startDate:  formatter.string(from: self.startPicker.date),endDate: formatter.string(from:self.endPicker.date))
        }
       
       
    }

    @IBAction func startingDate(_ sender: Any) {
      
    }
    @IBAction func endingDate(_ sender: Any) {
        
    
    }
    
    
    func addParking(lati:String , long:String ,url:String,price:String,startDate:String , endDate:String){
        let info = [
            "Lati":  lati,
            "Long": long,
            "Reserved": "false",
            "Date":   "soon",
            "PhotoUrl": url,
            "Price": price,
            "Username" : Auth.auth().currentUser?.displayName!,
            "StartDate" : startDate,
            "EndDate" : endDate,
            "ID" : lati+long
        ]
        
        ref.child("parking").childByAutoId().setValue(info)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    func createAlert(title:String , message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
