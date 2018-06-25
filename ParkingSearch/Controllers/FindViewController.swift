//
//  FindeViewController.swift
//  ParkingSearch
//
//  Created by Teodoro Gomes on 25/06/2018.
//  Copyright © 2018 Teodoro Gomes. All rights reserved.
//

import UIKit

import UIKit
import MapKit
import CoreLocation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth



class FindViewController: UIViewController , CLLocationManagerDelegate,MKMapViewDelegate {
    
    let manager = CLLocationManager()
    var myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0,0)
    var databaseRef = Database.database().reference()
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        readFromFirebase()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Add Free Parking in current location
    
    
    @IBAction func addParkingSpot(_ sender: Any) {
        
        createAlert(title:"Free Parking Lot" , message: "Do you want to report a parking lot in your current Location ?")
    }
    
    func writeToFirebase(){
        let info = [
            "Lati":  String(myLocation.latitude),
            "Long": String(myLocation.longitude),
            "Reserved": "false",
            "Date":   "soon",
            "PhotoUrl": "none",
            "Price": "0",
            "Username" : Auth.auth().currentUser?.displayName! ?? "null",
            "StartDate" : "none",
            "EndDate" : "none",
            "ID" : String(myLocation.latitude+myLocation.longitude)
            ] as [String : Any]
        
        databaseRef.child("parking").childByAutoId().setValue(info)
        print("done")
    }
    
    
    
    
    //Add Parking Annotations
    func AddParkingOnMapFromFirebase(pinLocation:CLLocationCoordinate2D,title:String){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinLocation
        annotation.title = title
        map.addAnnotation(annotation)
    }
    
    //Location
    
    @IBAction func getUserLocation(_ sender: Any) {
        let span :MKCoordinateSpan = MKCoordinateSpanMake(0.01,0.01)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        
    }
    
    //Getting Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        self.map.showsUserLocation = true
    }
    
    
   
    
    func readFromFirebase(){
        databaseRef.child("parking").observe(.value) { (snapshot) in
            var title:String = "Free Parking"
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                guard let dict = child.value as? [String: Any] else { continue }
                let lati = dict["Lati"] as! String
                let long = dict["Long"] as! String
                let price = dict["Price"] as! String
                let reserved = dict["Reserved"] as! String
                if(price != "0"){
                    title = "\(price)/Hour €"
                }
                self.AddParkingOnMapFromFirebase(pinLocation: CLLocationCoordinate2DMake(Double(lati)!, Double(long)!),title: title)
            }
        }
        
    }
    
    func createAlert(title:String , message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            self.writeToFirebase()
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            let button = UIButton(type: .detailDisclosure)
            button.addTarget(self, action: #selector(infoClicked), for: .touchUpInside)
            view.rightCalloutAccessoryView = button
            let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
            if(annotation.title == "Free Parking"){
                leftIconView.image = #imageLiteral(resourceName: "freeParkingImage")
            }else{
                leftIconView.image = #imageLiteral(resourceName: "paid-parking")
            }
           
            view.leftCalloutAccessoryView = leftIconView
        }
        return view
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //Getting ID
//        String((view.annotation?.coordinate.latitude)!+(view.annotation?.coordinate.longitude)!)
        databaseRef.queryOrdered(byChild: "ID").queryEqual(toValue: "61.6732223358654").observe(.value) { (snapshot) in
        }
    }
    
    @objc  func infoClicked(){
//        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "infoViewController") as! infoViewController
//
//        self.navigationController.pushViewController(secondViewController, animated: true)
        performSegue(withIdentifier: "infoSegue", sender: self)
    }
    
    
    
    
}
