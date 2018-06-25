//
//  RegisterViewController.swift
//  ParkingSearch
//
//  Created by Teodoro Gomes on 01/06/2018.
//  Copyright © 2018 Teodoro Gomes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class RegisterViewController: UIViewController, CLLocationManagerDelegate{

    
    @IBOutlet var map: MKMapView!
   var ref: DatabaseReference!
    
  
    let manager = CLLocationManager();
    var myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01,0.01)
         myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
        print(myLocation)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self;
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sumbitLot(_ sender: UIButton) {
        createAlert(title: "Free Parking Lot", message: "Are you sure you want to sumbit a Emplyt slot?")
    }
    
    
    
    
    func createAlert(title:String , message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            self.addAnnotation()
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel",style:UIAlertActionStyle.cancel,handler: { (action) in
            alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addAnnotation(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = myLocation
        annotation.title = "Parking Lot"
        annotation.subtitle = "Sumbited 5 Minutes Ago"
        map.addAnnotation(annotation)
        
        //to the database
        
        let info = [
            "Lati":  String(myLocation.latitude),
            "Long": String(myLocation.longitude),
            "date":   "soon"
        ]
        ref.child("parkingLocation").childByAutoId().setValue(info)
        
        
    
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
