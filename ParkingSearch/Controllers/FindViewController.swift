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



class FindViewController: UIViewController , CLLocationManagerDelegate,MKMapViewDelegate , UISearchBarDelegate{
    
  
    
    @IBAction func searchButton(_ sender: Any) {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController,animated: true,completion: nil)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Activity indicator
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //Hide SearchBar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Create the Search Request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activitySearch = MKLocalSearch(request: searchRequest)
        
        activitySearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                print("Error")
            }else{
                
                
                //Getting Data
                let latidude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
               
                
                //Zooming Annotation
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latidude!, longitude!)
                let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(coordinate, span)
                self.map.setRegion(region, animated: true)
            }
        }
        
    }
    
    
    
    
    let manager = CLLocationManager()
    var IDtoSend:String = ""
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

                if(price == "0"){
                    title = "Free Parking"
                }else{
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
            self.readFromFirebase()
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
            }else {
                
                leftIconView.image = #imageLiteral(resourceName: "paid-parking")
            }
           
            view.leftCalloutAccessoryView = leftIconView
        }
        return view
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       let annotation = view.annotation as? MKAnnotation
        if annotation is MKUserLocation {
            return
        }
        
        IDtoSend = String((annotation?.coordinate.latitude)!) + String((annotation?.coordinate.longitude)!)
        if( annotation?.title == "Free Parking"){
            IDtoSend = "-1"
        }
        
        
    }
    
    @objc  func infoClicked(){
        performSegue(withIdentifier: "infoSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as? infoViewController
        viewController?.ID = IDtoSend
    }
    
    
    
    
}
