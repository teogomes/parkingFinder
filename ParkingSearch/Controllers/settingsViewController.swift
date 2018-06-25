//
//  settingsViewController.swift
//  ParkingSearch
//
//  Created by Teodoro Gomes on 08/06/2018.
//  Copyright © 2018 Teodoro Gomes. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class settingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        do {
            try Auth.auth().signOut()
            FBSDKAccessToken.setCurrent(nil)
            
        } catch let error as NSError {
            print(error.localizedDescription)
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
