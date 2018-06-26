//
//  infoViewController.swift
//  ParkingSearch
//
//  Created by Teodoro Gomes on 25/06/2018.
//  Copyright © 2018 Teodoro Gomes. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
class infoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    public var  ID:String = ""
    @IBOutlet weak var priceText: UILabel!
    @IBOutlet weak var usernameText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(ID == "-1"){
           
        }else{
            downloadImage()
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUrl(completion: @escaping (_ result: String , _ _username: String, _ price: String) -> Void){
        var downloadUrl:String = "";
        var username:String = ""
        var price:String = ""
        let dbref = Database.database().reference().child("parking")
        let query = dbref.queryOrdered(byChild: "ID").queryEqual(toValue: ID)
        query.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: Any]
                 username = dict["Username"] as! String
                 downloadUrl = dict["PhotoUrl"] as! String
                price = dict["Price"] as! String
                
            }
            completion(downloadUrl , username , price)
        }
    }
    
    func downloadImage(){
        getUrl { (url,username,price) in
            
            let storageRef = Storage.storage().reference(forURL: url)
            storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                let image = UIImage(data: data!)
                self.imageView.image = image
        }
            self.usernameText.text = "By \(username)"
            self.priceText.text = price
        
        }
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
