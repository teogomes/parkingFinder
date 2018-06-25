//
//  infoViewController.swift
//  ParkingSearch
//
//  Created by Teodoro Gomes on 25/06/2018.
//  Copyright © 2018 Teodoro Gomes. All rights reserved.
//

import UIKit
import FirebaseStorage

class infoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadImage()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadImage(){
        let storageRef = Storage.storage().reference(forURL: "https://firebasestorage.googleapis.com/v0/b/parkingfinder-9f852.appspot.com/o/parkingImages%2F35.295442584808324.9300385.png?alt=media&token=c1e5a959-1016-48dc-9fc7-4f880eedc820")

        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            let image = UIImage(data: data!)
            self.imageView.image = image
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
